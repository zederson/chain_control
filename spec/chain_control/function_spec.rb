RSpec.describe ChainControl::Function do
  let(:target) { 0 }
  let(:validation) { :zero? }
  let(:operation) { 'ok' }
  let(:options) { {} }

  let(:function) do
    ChainControl::Function.new(target, validation, operation, options)
  end

  describe '#applicable?' do
    subject { function.applicable? }

    context 'when applicable' do
      context 'when validation is method to target' do
        let(:validation) { :zero? }
        it { is_expected.to be_truthy }
      end

      context 'when validation is callable' do
        let(:validation) { -> { 0.zero? } }
        it { is_expected.to be_truthy }
      end

      context 'when validation is boolean' do
        let(:validation) { true }
        it { is_expected.to be_truthy }
      end
    end

    context 'when no applicable' do
      let(:validation) { -> { 1 == 3 } }
      it { is_expected.to be_falsey }
    end
  end

  describe '#handler' do
    subject { function.handler }

    context 'when no have successor' do
      context 'when applicable' do
        it { is_expected.to eq 'ok' }
      end

      context 'when no applicable' do
        let(:validation) { false }
        it { is_expected.to be_nil }
      end
    end

    context 'when hava successor' do
      let(:validation) { :nil? }
      before do
        5.times do |index|
          val = -> { index == 3 }
          operation = "ok - #{index}"
          func = ChainControl::Function.new(index, val, operation)
          function.add_successor func
        end
      end

      it { is_expected.to eq 'ok - 3' }
    end

    context 'when no have a validation' do
      let(:validation) { :nil? }
      before do
        5.times do |index|
          func = ChainControl::Function.new(index, false, 'ok')
          function.add_successor func
        end
      end

      it { is_expected.to be_nil }
    end

    context 'when use cache' do
      let(:options) { { cache: true } }
      let(:validation) { :nil? }
      let(:result) { double }

      before do
        5.times do |index|
          val = -> { index == 3 }
          op = -> { result.anything }
          func = ChainControl::Function.new(index, val, op, options)
          function.add_successor func
        end
      end

      it 'execute once' do
        expect(result).to receive(:anything).and_return('ok_cache')

        expect(function.handler).to eq 'ok_cache'
        expect(function.handler).to eq 'ok_cache'
        expect(function.handler).to eq 'ok_cache'
        expect(function.handler).to eq 'ok_cache'
      end
    end

    context '#add_successor' do
      let(:successor) { ChainControl::Function.new(1, true, 'ok') }

      context 'when no have a successor' do
        before { function.add_successor successor }

        it 'should be successor function' do
          expect(function.successor).to eq successor
        end
        it 'should be size 2' do
          expect(function.level).to be 2
        end
      end

      context 'when have successor function' do
        let(:other) { ChainControl::Function.new(2, true, 'ok') }

        before do
          function.add_successor successor
          function.add_successor other
        end

        it 'should be size 3' do
          expect(function.level).to be 3
        end
      end
    end

    context '#level' do
      subject { function.level }

      it { is_expected.to be 1 }

      context 'when has more sucessors' do
        let(:other) { ChainControl::Function.new(2, true, 'ok') }

        before { function.add_successor other }

        it { is_expected.to be 2 }
      end
    end
  end
end
