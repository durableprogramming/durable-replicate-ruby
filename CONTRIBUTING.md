# Contributing to Replicate Ruby Client

Thank you for your interest in contributing to the Replicate Ruby client! We welcome contributions from the community and are grateful for your help in making this project better.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Community](#community)

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you agree to:

- Be respectful and inclusive
- Focus on constructive feedback
- Accept responsibility for mistakes
- Show empathy towards other contributors
- Help create a positive community

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Set up your development environment** (see below)
4. **Create a feature branch** for your changes
5. **Make your changes** following our guidelines
6. **Write tests** for your changes
7. **Submit a pull request**

## Development Setup

### Prerequisites

- Ruby 2.6.0 or higher
- Bundler

### Setup Steps

1. Clone your fork:
   ```bash
   git clone https://github.com/yourusername/replicate-ruby.git
   cd replicate-ruby
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run the tests to ensure everything works:
   ```bash
   bundle exec rake test
   ```

4. Start a console session for experimentation:
   ```bash
   bin/console
   ```

## How to Contribute

### Types of Contributions

- **Bug fixes**: Fix issues in the codebase
- **Features**: Add new functionality
- **Documentation**: Improve documentation, examples, or guides
- **Tests**: Add or improve test coverage
- **Code quality**: Refactor code, improve performance, or enhance maintainability

### Finding Issues

- Check the [GitHub Issues](https://github.com/dreamingtulpa/replicate-ruby/issues) for open issues
- Look for issues labeled `good first issue` or `help wanted`
- Comment on an issue to indicate you're working on it

## Development Guidelines

### Code Style

We use [RuboCop](https://rubocop.org/) for code style enforcement. The rules are defined in `.rubocop.yml`.

- Run RuboCop before submitting:
  ```bash
  bundle exec rubocop
  ```

- Auto-fix issues where possible:
  ```bash
  bundle exec rubocop -a
  ```

### Naming Conventions

- **Modules/Classes**: PascalCase (e.g., `Replicate::Client`)
- **Methods**: snake_case (e.g., `retrieve_model`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `VERSION`)
- **Files**: snake_case matching class/module names

### Documentation

- Use YARD format for all public methods
- Include parameter types, return values, and examples
- Document exceptions that may be raised

Example:
```ruby
# Creates a prediction using this model version
#
# @param input [Hash] The input parameters for the model
# @param webhook [String, nil] Optional webhook URL
# @return [Replicate::Record::Prediction] The created prediction
# @raise [Replicate::Error] If prediction creation fails
def predict(input, webhook = nil)
  # implementation
end
```

### Commit Messages

Follow conventional commit format:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Maintenance tasks

Examples:
- `feat: add support for model collections`
- `fix: handle timeout errors in predictions`
- `docs: update README with webhook examples`

## Testing

### Running Tests

```bash
# Run all tests
bundle exec rake test

# Run specific test file
bundle exec ruby test/replicate/client_test.rb
```

### Writing Tests

- Use Minitest framework
- Test files should be in `test/` directory
- Mirror the lib structure (e.g., `test/replicate/client_test.rb`)
- Use descriptive test names
- Test both success and failure cases
- Use WebMock for HTTP request mocking

Example test structure:
```ruby
class ClientTest < Minitest::Test
  def test_retrieve_model_success
    # Test successful model retrieval
  end

  def test_retrieve_model_not_found
    # Test error handling for non-existent models
  end
end
```

### Test Coverage

Maintain high test coverage (>90%). Run coverage reports with:

```bash
# If using simplecov
bundle exec rake test
# Check coverage/index.html
```

## Submitting Changes

### Pull Request Process

1. **Create a feature branch** from `master`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the guidelines above

3. **Run the full test suite**:
   ```bash
   bundle exec rake test
   bundle exec rubocop
   ```

4. **Update documentation** if needed

5. **Commit your changes** with clear messages

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** on GitHub:
   - Use a clear title describing the change
   - Provide a detailed description of what was changed and why
   - Reference any related issues
   - Ensure CI checks pass

### Pull Request Requirements

- [ ] Tests pass
- [ ] Code style checks pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] Commit messages follow conventional format

### Review Process

- A maintainer will review your PR
- They may request changes or ask questions
- Once approved, your PR will be merged
- You may be asked to squash commits for cleaner history

## Developer Certificate of Origin

By contributing to this project, you agree to the Developer Certificate of Origin (DCO):

```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
1 Letterman Drive
Suite D4700
San Francisco, CA, 94129

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.

Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, or not, under the license indicated in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```

To sign your commits, use `git commit -s` or add the following to your commit message:

```
Signed-off-by: Your Name <your.email@example.com>
```

## Community

- **Discussions**: Use GitHub Discussions for questions and general discussion
- **Issues**: Report bugs and request features via GitHub Issues
- **Code Reviews**: All changes require review before merging
- **Recognition**: Contributors are acknowledged in release notes

Thank you for contributing to the Replicate Ruby client! 🎉</content>
</xai:function_call">