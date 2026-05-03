# Skip scenarios tagged @pending. These represent activities documented
# in the user guide whose Cucumber implementation hasn't landed yet (or
# whose underlying feature in the app isn't built yet — e.g. §4e Mark
# Won/Lost). They show as skipped, not failing, so the test summary stays
# honest about coverage gaps.
Before("@pending") do
  skip_this_scenario("Pending — see the user guide §ref in the scenario name")
end
