require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "missing_env_vars surfaces TEST_TO_EMAIL in development when unset" do
    with_env(test_to_email: nil) do
      with_development(true) do
        assert_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  test "missing_env_vars omits TEST_TO_EMAIL in development when it is set" do
    with_env(test_to_email: "qa@example.com") do
      with_development(true) do
        refute_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  test "missing_env_vars does not surface TEST_TO_EMAIL outside development" do
    with_env(test_to_email: nil) do
      with_development(false) do
        refute_includes missing_env_vars, "TEST_TO_EMAIL"
      end
    end
  end

  private

  def with_env(test_to_email:)
    prior = ENV["TEST_TO_EMAIL"]
    if test_to_email.nil?
      ENV.delete("TEST_TO_EMAIL")
    else
      ENV["TEST_TO_EMAIL"] = test_to_email
    end
    yield
  ensure
    if prior.nil?
      ENV.delete("TEST_TO_EMAIL")
    else
      ENV["TEST_TO_EMAIL"] = prior
    end
  end

  def with_development(value)
    original = ApplicationHelper.instance_method(:development_environment?)
    ApplicationHelper.define_method(:development_environment?) { value }
    yield
  ensure
    ApplicationHelper.define_method(:development_environment?, original)
  end
end
