## Contributing

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and
   it's great to know that you have a clean slate

3. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.

4. Make the test pass.

5. Push to your fork and submit a pull request.

## Dependencies

The testing and development tools have a bunch of dependencies,
all managed by [bundler](http://bundler.io/) according to the
[Puppet support matrix](http://docs.puppetlabs.com/guides/platforms.html#ruby-versions).
By default the tests use a baseline version of Puppet.

If you have Ruby 2.x or want a specific version of Puppet,
you must set an environment variable such as:

    export PUPPET_GEM_VERSION="~> 3.2.0"

Install the dependencies like so...

    bundle install

...or promote reuse of bundled gems across projects by running:

    bundle install --path=~/.bundle

## Syntax and style

The test suite will run [Puppet Lint](http://puppet-lint.com/) and
[Puppet Syntax](https://github.com/gds-operations/puppet-syntax) to
check various syntax and style things. You can run these locally with:

    bundle exec rake lint
    bundle exec rake syntax
    bundle exec metadata_lint
    bundle exec rubocop

See Travis configuration for all syntax and style tests.

## Running the unit tests

The unit test suite covers most of the code, as mentioned above please
add tests if you're adding new functionality. If you've not used
[rspec-puppet](http://rspec-puppet.com/) before then feel free to ask
about how best to test your new feature. Running the test suite is done
with:

    bundle exec rake spec

To run in parallel:

    bundle exec rake parallel_spec
