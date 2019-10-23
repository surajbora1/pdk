require 'spec_helper'
require 'pdk/cli'

describe 'Running `pdk new module`' do
  subject { PDK::CLI.instance_variable_get(:@new_module_cmd) }

  context 'when not passed a module name' do
    context 'and run without --skip-interview' do
      it 'continues to module interview' do
        expect(PDK::Generate::Module).to receive(:invoke)
        expect(logger).to receive(:info).with(%r{Creating new module:})
        PDK::CLI.run(%w[new module])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          output_format: 'default',
          ruby_version: RUBY_VERSION,
        )

        PDK::CLI.run(%w[new module])
      end
    end

    context 'and run with --skip-interview' do
      it 'exits with an error' do
        expect(logger).to receive(:error).with(%r{must specify a module name}i)

        expect { PDK::CLI.run(%w[new module --skip-interview]) }.to exit_nonzero
      end

      it 'submits the command to analytics' do
        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'skip-interview=true',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        expect { PDK::CLI.run(%w[new module --skip-interview]) }.to exit_nonzero
      end
    end
  end

  context 'when passed an invalid module name' do
    it 'informs the user that the module name is invalid' do
      expect(logger).to receive(:error).with(a_string_matching(%r{'123test'.*not.*valid module name}m))

      expect { PDK::CLI.run(%w[new module 123test]) }.to exit_nonzero
    end

    # Unlike most other commands, the validation of parameters does not happen
    # at the CLI layer as they can be later modified during the interview.
    # FIXME - extract validation logic so module name can be validated here if
    # specified
    it 'submits the command to analytics' do
      expect(analytics).to receive(:screen_view).with(
        'new_module',
        output_format: 'default',
        ruby_version:  RUBY_VERSION,
      )

      expect { PDK::CLI.run(%w[new module 123test]) }.to exit_nonzero
    end
  end

  context 'when passed a valid module name' do
    let(:module_name) { 'test123' }

    it 'validates the module name' do
      expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(module_name: module_name))
      expect(logger).to receive(:info).with("Creating new module: #{module_name}")
      PDK::CLI.run(['new', 'module', module_name])
    end

    it 'submits the command to analytics' do
      allow(PDK::Generate::Module).to receive(:invoke)

      expect(analytics).to receive(:screen_view).with(
        'new_module',
        output_format: 'default',
        ruby_version:  RUBY_VERSION,
      )

      PDK::CLI.run(['new', 'module', module_name])
    end

    context 'and a target directory' do
      let(:target_dir) { 'target' }

      it 'passes the target directory to PDK::Generate::Module.invoke' do
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(module_name: module_name, target_dir: target_dir))
        expect(logger).to receive(:info).with("Creating new module: #{module_name}")
        PDK::CLI.run(['new', 'module', module_name, target_dir])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', module_name, target_dir])
      end
    end

    context 'and the template-url option' do
      let(:template_url) { 'https://github.com/myuser/my-pdk-template' }

      it 'passes the value of the template-url option to PDK::Generate::Module.invoke' do
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(:'template-url' => template_url))
        expect(logger).to receive(:info).with("Creating new module: #{module_name}")
        PDK::CLI.run(['new', 'module', '--template-url', template_url, module_name])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'template-url=redacted',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', '--template-url', template_url, module_name])
      end
    end

    context 'and the template-ref without the template-url option' do
      let(:template_ref) { '1.0.0' }

      it 'does not invoke PDK::Generate::Module' do
        expect(PDK::Generate::Module).not_to receive(:invoke)
        expect { PDK::CLI.run(['new', 'module', '--template-ref', template_ref, module_name]) }.to exit_nonzero
      end

      it 'does not submit a command to analytics' do
        expect(analytics).not_to receive(:screen_view)

        expect { PDK::CLI.run(['new', 'module', '--template-ref', template_ref, module_name]) }.to exit_nonzero
      end
    end

    context 'and the license option' do
      let(:license) { 'MIT' }

      it 'passes the value of the license option to PDK::Generate::Module.invoke' do
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(license: license))
        expect(logger).to receive(:info).with("Creating new module: #{module_name}")
        PDK::CLI.run(['new', 'module', '--license', license, module_name])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'license=redacted',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', '--license', license, module_name])
      end
    end

    context 'and the skip-interview flag' do
      it 'passes true as the value of the skip-interview option to PDK::Generate::Module.invoke' do
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(:'skip-interview' => true))
        expect(logger).to receive(:info).with("Creating new module: #{module_name}")
        PDK::CLI.run(['new', 'module', '--skip-interview', module_name])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'skip-interview=true',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', '--skip-interview', module_name])
      end
    end

    context 'and the full-interview flag' do
      it 'passes true as the value of the full-interview option to PDK::Generate::Module.invoke' do
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(:'full-interview' => true))
        expect(logger).to receive(:info).with("Creating new module: #{module_name}")
        PDK::CLI.run(['new', 'module', '--full-interview', module_name])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'full-interview=true',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', '--full-interview', module_name])
      end
    end

    context 'and the --skip-interview and --full-interview flags have been passed' do
      it 'ignores full-interview and continues with a log message' do
        expect(logger).to receive(:info).with(a_string_matching(%r{Ignoring --full-interview and continuing with --skip-interview.}i))
        expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(:'skip-interview' => true, :'full-interview' => false))

        PDK::CLI.run(['new', 'module', '--skip-interview', '--full-interview', module_name])
      end

      it 'submits the command to analytics' do
        allow(PDK::Generate::Module).to receive(:invoke)

        expect(analytics).to receive(:screen_view).with(
          'new_module',
          cli_options:   'skip-interview=true,full-interview=true',
          output_format: 'default',
          ruby_version:  RUBY_VERSION,
        )

        PDK::CLI.run(['new', 'module', '--skip-interview', '--full-interview', module_name])
      end
    end
  end

  context 'when passed a module name with a forge user' do
    let(:module_name) { 'user-test123' }

    it 'validates and parses the module name' do
      expect(PDK::Generate::Module).to receive(:invoke).with(hash_including(module_name: 'test123', username: 'user'))
      expect(logger).to receive(:info).with("Creating new module: #{module_name}")
      PDK::CLI.run(['new', 'module', module_name])
    end

    it 'submits the command to analytics' do
      allow(PDK::Generate::Module).to receive(:invoke)

      expect(analytics).to receive(:screen_view).with(
        'new_module',
        output_format: 'default',
        ruby_version:  RUBY_VERSION,
      )

      PDK::CLI.run(['new', 'module', module_name])
    end
  end
end
