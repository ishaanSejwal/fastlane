describe Fastlane do
  describe Fastlane::Action do
    describe "#action_name" do
      it "converts the :: format to a readable one" do
        expect(Fastlane::Actions::IpaAction.action_name).to eq('ipa')
        expect(Fastlane::Actions::IncrementBuildNumberAction.action_name).to eq('increment_build_number')
      end
    end

    describe "Easy access to the lane context" do
      it "redirects to the correct class and method" do
        Fastlane::Actions.lane_context[:something] = 1
        expect(Fastlane::Action.lane_context).to eq({ something: 1 })
      end
    end

    describe "can call alias action" do
      it "redirects to the correct class and method" do
        result = Fastlane::FastFile.new.parse("lane :test do
          println \"alias\"
        end").runner.execute(:test)
      end

      it "alias can override option" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          somealias(example: \"alias\", example_two: 'alias2')
        end").runner.execute(:test)
      end

      it "alias can override option with single param" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          someshortalias('PARAM')
        end").runner.execute(:test)
      end

      it "alias can override option with no param" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        expect(UI).to receive(:important).with("modified")
        result = Fastlane::FastFile.new.parse("lane :test do
          somealias_no_param('PARAM')
        end").runner.execute(:test)
      end
    end

    describe "Call another action from an action" do
      it "allows the user to call it using `other_action.rocket`" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileActionFromAction')

        response = {
          rocket: "🚀",
          pwd: Dir.pwd
        }
        expect(ff.runner.execute(:something, :ios)).to eq(response)
      end

      it "shows an appropriate error message when trying to directly call an action" do
        Fastlane::Actions.load_external_actions("spec/fixtures/actions")
        ff = Fastlane::FastFile.new('./spec/fixtures/fastfiles/FastfileActionFromActionInvalid')
        expect do
          ff.runner.execute(:something, :ios)
        end.to raise_error("To call another action from an action use `OtherAction.rocket` instead")
      end
    end
  end
end
