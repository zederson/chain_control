RSpec.describe ChainControl do
  it { expect(ChainControl::VERSION).not_to be nil }

  describe '.instance' do
    let(:target) { 2 }
    subject { ChainControl.instance(target) }

    it { is_expected.to be_an_instance_of(ChainControl::Base) }
  end

  describe 'when no have target' do
    let(:service) { ChainControl.instance }

    before do
      service
        .add(-> { false }, 1)
        .add(false, 2)
        .add(true, 3)
        .add(false, 4)
    end

    subject { service.execute }

    it { is_expected.to be(3) }
  end

  describe 'when verifier is lambda' do
    let(:service) { ChainControl.instance(5) }
    subject { service.add(-> { true }, 1).execute }

    it { is_expected.to be(1) }
  end

  describe 'when verifier is reference to method' do
    let(:service) { ChainControl.instance(0) }
    subject { service.add(:zero?, 'ok').execute }

    it { is_expected.to eq 'ok' }
  end

  describe 'when verifier is boolean' do
    let(:aux) { 1 }
    let(:service) { ChainControl.instance(0) }
    subject { service.add(aux == 1, 'ok').execute }

    it { is_expected.to eq 'ok' }
  end

  describe 'simplified call' do
    let(:service) { ChainControl.instance(0) }

    subject { service.execute }

    context 'simple call' do
      before { service[:zero?] = -> { 'ok' } }

      it { is_expected.to eq 'ok' }
    end

    context 'more validations' do
      let(:aux) { 5 }

      before do
        service[false] = 1
        service[-> { aux == 5 }] = 2
        service[true] = 3
      end

      it { is_expected.to eq 2 }
    end
  end

  describe 'using default value' do
    let(:service) { ChainControl.instance(2, default: 'ok') }
    before do
      service
        .add(false, 2)
        .add(false, 4)
    end

    subject { service.execute }

    it { is_expected.to eq 'ok' }
  end

  describe 'using cache' do
    let(:service) { ChainControl.instance }
    let(:result) { double }

    context 'when use cache on add' do
      before do
        service
          .add(false, 2)
          .add(true, -> { result.anything }, cache: true)
          .add(false, 4)
      end

      it 'should run once' do
        expect(result).to receive(:anything).and_return(2)
        expect(service.execute).to eq 2
        expect(service.execute).to eq 2
        expect(service.execute).to eq 2
        expect(service.execute).to eq 2
      end
    end

    context 'when use cache to all verifiers' do
      let(:service) { ChainControl.instance(0, cache: true) }

      before do
        service
          .add(false, 2)
          .add(:zero?, -> { result.anything })
          .add(false, 4)
      end

      it 'should run once' do
        two = 2
        expect(result).to receive(:anything).and_return(two)
        expect(service.execute).to eq two
        expect(service.execute).to eq two
        expect(service.execute).to eq two
        expect(service.execute).to eq two
      end
    end
  end
end
