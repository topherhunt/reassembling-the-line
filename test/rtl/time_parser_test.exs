# TODO: Try moving this to a Videos context test
defmodule RTL.TimeParserTest do
  use RTL.DataCase, async: true
  import RTL.TimeParser

  test "#string_to_float works" do
    assert string_to_float("1") == 1.0

    assert string_to_float("0.05") == 0.05

    assert string_to_float("0:00.1") == 0.1

    assert string_to_float("2:16") == 136.0

    assert string_to_float("99:99.92") == 6039.92

    assert string_to_float("61:00") == 3660

    assert string_to_float(nil) == nil
  end

  test "#float_to_string works" do
    assert float_to_string(1.0) == "0:01"

    assert float_to_string(33.01) == "0:33.01"

    assert float_to_string(99.3) == "1:39.3"

    assert float_to_string(789.25) == "13:09.25"

    assert float_to_string(3000.99) == "50:00.99"

    assert float_to_string(5000.0) == "83:20"

    assert float_to_string(nil) == nil
  end
end
