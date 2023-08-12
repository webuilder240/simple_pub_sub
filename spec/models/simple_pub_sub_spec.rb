require 'rails_helper'

RSpec.describe SimplePubSub do
  class DummyPayload
  end

  class DummySubscriber
    def call(payload); end
  end

  describe 'subscribe' do
    context '購読の登録' do
      it '購読が正常に登録されること' do
        SimplePubSub.subscribe(:test_event, DummySubscriber.new, DummyPayload)
        expect(SimplePubSub.subscriptions[:test_event]).not_to be_nil
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

  xdescribe 'スレッドセーフ性' do
    let(:subscriber) { DummySubscriber.new }

    context ".subscribe" do
      it '異なるスレッド間で設定が共有されないこと' do
        thread = Thread.new do
          SimplePubSub.subscribe(:test_event, subscriber, DummyPayload)
        end

        thread.join

        # expect(subscriber).to receive(:call)
        expect(SimplePubSub.subscriptions[:test_event]).to eq nil
      end
    end

    xcontext ".subscribe" do
      before do
        SimplePubSub.subscribe(:test_event, subscriber, DummyPayload)
      end

      it '異なるスレッド間で設定が共有されないこと' do
        thread = Thread.new do
          SimplePubSub.mute_within(:test_event) do
            expect(subscriber).not_to receive(:call)
            SimplePubSub.publish(:test_event, DummyPayload.new)
          end
        end

        thread.join

        expect(subscriber).to receive(:call)
        SimplePubSub.publish(:test_event, DummyPayload.new)
      end
    end

  end
end
