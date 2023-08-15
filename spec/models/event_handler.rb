require 'rails_helper'

RSpec.describe EventHandler do
  class Payload
  end

  class Handler
    def call(payload); end
  end

  before do
    # イベント名のモジュールを設定
    module EventNames
      TEST_EVENT = :test_event unless defined?(TEST_EVENT)
      NO_ARGS_EVENT = :no_args_event unless defined?(NO_ARGS_EVENT)
    end
    EventHandler.event_names_module = EventNames
  end

  describe 'listen' do
    context '購読の登録' do
      it '購読が正常に登録されること' do
        EventHandler.listen(:test_event, Handler.new, Payload)
        expect(EventHandler.listeners[:test_event]).not_to be_nil
      end
    end

    context '引数がない場合' do
      before do
        module NoArgsEvent
          class Handler
            def call(payload); end
          end
        end

        module NoArgsEvent
          class Payload; end
        end
      end

      it 'SubscriberとPayloadのクラスが動的に読み込まれて購読が登録されること' do
        expect { EventHandler.listen(:no_args_event) }.not_to raise_error
        expect(EventHandler.listeners[:no_args_event]).not_to be_nil
      end

      after do
        # Cleanup
        NoArgsEvent.send(:remove_const, :Payload)
        NoArgsEvent.send(:remove_const, :Handler)
      end
    end
  end

  describe 'publish' do
    let(:listener) { Handler.new }

    before do
      EventHandler.listen(:test_event, listener, Payload)
    end

    context '正しいペイロードを指定した場合' do
      it 'サブスクライバのcallが呼び出されること' do
        expect(listener).to receive(:call)
        EventHandler.publish(:test_event, Payload.new)
      end
    end

    context '不正なペイロードを指定した場合' do
      it 'エラーが発生すること' do
        expect { EventHandler.publish(:test_event, Object.new) }.to raise_error(EventHandler::InvalidPayloadError)
      end
    end
  end

  describe 'mute_within' do
    let(:listener) { Handler.new }

    before do
      EventHandler.listen(:test_event, listener, Payload)
    end

    context 'イベントがミュートされている間' do
      it 'サブスクライバのcallが呼び出されないこと' do
        expect(listener).not_to receive(:call)
        EventHandler.mute_within(:test_event) do
          EventHandler.publish(:test_event, Payload.new)
        end
      end
    end

    context 'ミュートが終了した後' do
      it 'サブスクライバのcallが呼び出されること' do
        EventHandler.mute_within(:test_event) do
          # ブロック内部
        end
        expect(listener).to receive(:call)
        EventHandler.publish(:test_event, Payload.new)
      end
    end
  end

end
