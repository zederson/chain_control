RSpec.describe ChainControl::Base do
  let(:service) { ChainControl::Base.new(target, options) }
  let(:target) { 2 }
  let(:options) { nil }

  describe '#instance' do
    subject { service }

    it { is_expected.to be_an_instance_of ChainControl::Base }

    it { expect(subject.options).to be_empty }

    context 'when has options' do
      let(:options) { { cache: true } }

      it { expect(subject.options).to include(cache: true) }
    end
  end

  describe '#add' do
    subject { service.add(:valid?, 2) }

    it { expect(subject.size).to be 1 }
    it { is_expected.to be_an_instance_of ChainControl::Base }

    context 'when have validations' do
      before do
        service.add(nil, 2)
        service.add(nil, 2)
      end

      subject { service.size }

      it { is_expected.to be(2) }
    end
  end

  describe '#execute' do
    subject { service.execute }

    context 'when function is nil' do
      it { is_expected.to be_nil }
    end

    context 'when has default value' do
      let(:options) { { default: 51 } }
      it { is_expected.to be 51 }
    end

    context 'when no valid function' do
      before do
        service.add(false, 2)
        service.add(false, 2)
      end

      it { is_expected.to be_nil }
    end

    context 'when has function valid' do
      before do
        service.add(false, 2)
        service.add(true, 3)
        service.add(false, 4)
      end

      it { is_expected.to be 3 }
    end

    context 'when use cache' do
      let(:result) { double }
      let(:options) { { cache: true } }

      before do
        service.add(false, 2)
        service.add(true, -> { result.ze })
        service.add(false, 4)
      end

      it 'should used cache' do
        expect(result).to receive(:ze).and_return('ze')

        service.execute
        service.execute
        service.execute
      end
    end
  end

  describe '#[]=' do
    before do
      service[:valid?] = false
      service[:invalid?] = false
    end

    subject { service }

    it { expect(subject.size).to be 2 }
    it { is_expected.to be_an_instance_of ChainControl::Base }
  end

  describe '#size' do
    subject { service.size }

    it { is_expected.to be_zero }
  end
end
