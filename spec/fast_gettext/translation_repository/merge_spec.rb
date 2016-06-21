require "spec_helper"

describe 'FastGettext::TranslationRepository::Merge' do
  describe "empty repo" do
    before do
      @rep = FastGettext::TranslationRepository.build('test', type: :merge)
    end

    it "has no locales" do
      @rep.available_locales.should == []
    end

    it "cannot translate" do
      @rep['car'].should == nil
    end

    it "cannot pluralize" do
      @rep.plural('Axis','Axis').should == []
    end

    it "has no pluralisation rule" do
      @rep.pluralisation_rule.should == nil
    end

    it "returns true on reload" do
      @rep.reload.should == true
    end
  end

  describe "filled repo" do
    before do
      FastGettext.locale = 'de'
      @one = FastGettext::TranslationRepository.build('test', path: File.join('spec', 'locale'), type: :mo)
      @two = FastGettext::TranslationRepository.build('test2', path: File.join('spec', 'locale'), type: :mo)

      @rep = FastGettext::TranslationRepository.build('test', type: :merge)
      @rep.add_repo(@one)
      @rep.add_repo(@two)
    end

    it "builds correct repo" do
      @rep.is_a?(FastGettext::TranslationRepository::Merge).should == true
    end

    describe "#available_locales" do
      it "should be the sum of all added repositories" do
        @one.should_receive(:available_locales).and_return ['de']
        @two.should_receive(:available_locales).and_return ['de','en']
        @rep.available_locales.should == ['de','en']
      end
    end

    describe "#[]" do
      it "uses the first repo for transaltion" do
        @rep['car'].should == 'Auto'
      end

      it "returns transaltion from the second repo when it doesn't exist in the first one" do
        @rep['Untranslated and translated in test2'].should == 'Translated'
      end
    end

    describe "#add_repo" do
      it "accepts mo repository" do
        mo_rep = FastGettext::TranslationRepository.build('test', path: File.join('spec', 'locale'), type: :mo)
        @rep.add_repo(mo_rep).should == true
      end

      it "accepts po repository" do
        po_rep = FastGettext::TranslationRepository.build('test', path: File.join('spec', 'locale'), type: :po)
        @rep.add_repo(po_rep).should == true
      end

      it "raises exeption for other repositories" do
        base_rep = FastGettext::TranslationRepository.build('test', path: File.join('spec', 'locale'), type: :base)
        lambda { @rep.add_repo(base_rep) }.should raise_error(RuntimeError)
      end
    end

    describe "#plural" do
      it "uses the first repo in the chain if it responds" do
        @one.should_receive(:plural).with('a','b').and_return ['A','B']
        @rep.plural('a','b').should == ['A','B']
      end

      it "uses the second repo in the chain if the first does not respond" do
        @one.should_receive(:plural).with('a','b').and_return []
        @two.should_receive(:plural).with('a','b').and_return ['A','B']
        @rep.plural('a','b').should == ['A','B']
      end

      it "returns empty array if no plural is faound" do
        @one.should_receive(:plural).with('a','b').and_return []
        @two.should_receive(:plural).with('a','b').and_return []
        @rep.plural('a','b').should == []
      end
    end

    describe "#pluralisation_rule" do
      it "chooses the first that exists" do
        @one.should_receive(:pluralisation_rule).and_return nil
        @two.should_receive(:pluralisation_rule).and_return 'x'
        @rep.pluralisation_rule.should == 'x'
      end
    end

    describe "#reload" do
      before do
        @rep = FastGettext::TranslationRepository.build('test', type: :merge)
        @rep.add_repo(FastGettext::TranslationRepository.build('test', path: File.join('spec', 'locale'), type: :mo))
        @rep['Untranslated and translated in test2'].should be_nil

        mo_file = FastGettext::MoFile.new('spec/locale/de/LC_MESSAGES/test2.mo')
        empty_mo_file = FastGettext::MoFile.empty

        FastGettext::MoFile.stub(:new).and_return(empty_mo_file)
        FastGettext::MoFile.stub(:new).with('spec/locale/de/LC_MESSAGES/test.mo', eager_load: false).and_return(mo_file)
      end

      it "can reload" do
        @rep.reload
        @rep['Untranslated and translated in test2'].should == 'Translated'
      end

      it "returns true" do
        @rep.reload.should == true
      end
    end
  end

  it "can work in SAFE mode" do
    pending_if RUBY_VERSION > "2.0" do
      `ruby spec/cases/safe_mode_can_handle_locales.rb 2>&1`.should == 'true'
    end
  end
end
