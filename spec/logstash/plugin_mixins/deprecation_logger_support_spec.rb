# encoding: utf-8

require "logstash-core"

require 'logstash/plugin_mixins/deprecation_logger_support'

##
# @subject deprecation_logger
# @requires: instance
shared_examples_for 'DeprecationLogger' do

  if !LogStash::PluginMixins::DeprecationLoggerSupport::NATIVE_SUPPORT_PROVIDED
    before(:each) do
      allow(instance.logger).to receive(:warn).with(any_args).and_return(nil)
    end
  end

  it { is_expected.to respond_to :deprecated }

  context '#deprecated' do
    context 'when sent a single argument' do
      it 'accepts a single string argument' do
        deprecation_logger.deprecated('this is a TEST')
      end

      if !LogStash::PluginMixins::DeprecationLoggerSupport::NATIVE_SUPPORT_PROVIDED
        it 'passes through to logger.warn' do
          deprecation_logger.deprecated('this is a TEST')
          expect(instance.logger).to have_received(:warn).with("DEPRECATED: this is a TEST")  
        end
      end
    end


    context 'when sent two arguments' do
      it 'accepts two arguments' do
        deprecation_logger.deprecated('this is a {}', 'TEST')
      end

      if !LogStash::PluginMixins::DeprecationLoggerSupport::NATIVE_SUPPORT_PROVIDED
        it 'passes both arguments to logger.warn' do
          deprecation_logger.deprecated('this is a {}', 'TEST')
          expect(instance.logger).to have_received(:warn).with("DEPRECATED: this is a {}", "TEST")  
        end
      end
    end
  end
end

##
# @subject: instance
# @param: method_name
# @varargs: params
shared_examples_for 'memoized method' do |method_name, *params|
  it 'returns the same object from successive calls' do
    first_return = instance.send(method_name, *params)
    second_return = instance.send(method_name, *params)

    expect(second_return).to eq(first_return)
  end
end

describe LogStash::PluginMixins::DeprecationLoggerSupport do
  let(:deprecation_logger_support) { LogStash::PluginMixins::DeprecationLoggerSupport }

  let(:class_including_loggable) { Class.new { include LogStash::Util::Loggable } }
  let(:class_not_including_loggable) { Class.new { } }

  context 'included into a class' do
    context 'that already includes Loggable' do
      let(:class_with_deprecation_logger_support) do
        Class.new(class_including_loggable) do
          include LogStash::PluginMixins::DeprecationLoggerSupport
        end
      end
      context 'when instantiated' do
        subject(:instance) { class_with_deprecation_logger_support.new }
        context '#deprecation_logger' do
          it_behaves_like 'memoized method', :deprecation_logger
          context 'the returned object' do
            it_behaves_like 'DeprecationLogger' do
              subject(:deprecation_logger) { instance.send(:deprecation_logger) }
            end
          end
        end
        context 'and class is a LogStash::Plugin' do
          let(:class_including_loggable) { Class.new(LogStash::Plugin) }
          subject(:instance) { class_with_deprecation_logger_support.new({}) }
          context '@deprecation_logger' do
            it_behaves_like 'DeprecationLogger' do
              subject(:deprecation_logger) { instance.instance_variable_get(:@deprecation_logger) }
            end
          end
        end
      end
    end
    context 'that does not include Loggable' do
      it 'errors helpfully' do
        expect { class_not_including_loggable.send(:include, LogStash::PluginMixins::DeprecationLoggerSupport) }
          .to raise_error(ArgumentError, /Loggable/)
      end
    end
  end

  context 'extended into an object' do
    context 'that is Loggable' do
      subject(:instance) { class_including_loggable.new }
      before(:each) { instance.extend(LogStash::PluginMixins::DeprecationLoggerSupport)}
      context '#deprecation_logger' do
        it_behaves_like 'memoized method', :deprecation_logger
        context 'the returned object' do
          it_behaves_like 'DeprecationLogger' do
            subject(:deprecation_logger) { instance.send(:deprecation_logger) }
          end
        end
      end
    end
    context 'that is not Loggable' do
      subject(:instance) { class_not_including_loggable.new }
      it 'errors helpfully' do
        expect { instance.extend(deprecation_logger_support) }
          .to raise_error(ArgumentError, /Loggable/)
      end
    end
  end
end
