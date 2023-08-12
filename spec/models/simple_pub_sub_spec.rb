require 'rails_helper'

RSpec.describe SimplePubSub do
  class DummyPayload
  end

  class DummySubscriber
    def call(payload); end
  end

  before do
    # イベント名のモジュールを設定
    module EventNames
      TEST_EVENT = :test_event unless defined?(TEST_EVENT)
      NO_ARGS_EVENT = :no_args_event unless defined?(NO_ARGS_EVENT)
    end
    SimplePubSub.event_names_module = EventNames
  end

  describe 'subscribe' do
    context '購読の登録' do
      it '購読が正常に登録されること' do
        SimplePubSub.subscribe(:test_event, DummySubscriber.new, DummyPayload)
        expect(SimplePubSub.subscriptions[:test_event]).not_to be_nil
      end
    end

    context '引数がない場合' do
      before do
        module Subscribers
          class NoArgsEvent
            def call(payload); end
          end
        end

        module Payloads
          class NoArgsEvent; end
        end
      end

      it 'SubscriberとPayloadのクラスが動的に読み込まれて購読が登録されること' do
        expect { SimplePubSub.subscribe(:no_args_event) }.not_to raise_error
        expect(SimplePubSub.subscriptions[:no_args_event]).not_to be_nil
      end

      after do
        # Cleanup
        Subscribers.send(:remove_const, :NoArgsEvent)
        Payloads.send(:remove_const, :NoArgsEvent)
      end
    end
  end

  describe 'publish' do
    let(:subscriber) { DummySubscriber.new }

    before do
      SimplePubSub.subscribe(:test_event, subscriber, DummyPayload)
    end

    context '正しいペイロードを指定した場合' do
      it 'サブスクライバのcallが呼び出されること' do
        expect(subscriber).to receive(:call)
        SimplePubSub.publish(:test_event, DummyPayload.new)
      end
    end

    context '不正なペイロードを指定した場合' do
      it 'エラーが発生すること' do
        expect { SimplePubSub.publish(:test_event, Object.new) }.to raise_error(SimplePubSub::InvalidPayloadError)
      end
    end
  end

  describe 'mute_within' do
    let(:subscriber) { DummySubscriber.new }

    before do
      SimplePubSub.subscribe(:test_event, subscriber, DummyPayload)
    end

    context 'イベントがミュートされている間' do
      it 'サブスクライバのcallが呼び出されないこと' do
        expect(subscriber).not_to receive(:call)
        SimplePubSub.mute_within(:test_event) do
          SimplePubSub.publish(:test_event, DummyPayload.new)
        end
      end
    end

    context 'ミュートが終了した後' do
      it 'サブスクライバのcallが呼び出されること' do
        SimplePubSub.mute_within(:test_event) do
          # ブロック内部
        end
        expect(subscriber).to receive(:call)
        SimplePubSub.publish(:test_event, DummyPayload.new)
      end
    end
  end

end
