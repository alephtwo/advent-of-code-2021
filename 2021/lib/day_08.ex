defmodule Day08 do
  @moduledoc """
  Day 8 of the Advent of Code 2021.
  """
  @type signal_t :: MapSet.t(String.t())
  @type parsed_line_t :: %{signals: list(signal_t()), output: list(signal_t())}

  # Here's what a proper 7-seg display looks like:
  #
  #  aaaa
  # b    c
  # b    c
  #  ....
  # e    f
  # e    f
  #  gggg
  #
  @correct_segments %{
    0 => "abcefg",
    1 => "cf",
    2 => "acdeg",
    3 => "acdfg",
    4 => "bcdf",
    5 => "abdfg",
    6 => "abdefg",
    7 => "acf",
    8 => "abcdefg",
    9 => "abcdfg"
  }

  @doc """
  You barely reach the safety of the cave when the whale smashes into the cave
  mouth, collapsing it. Sensors indicate another exit to this cave at a much
  greater depth, so you have no choice but to press on.

  As your submarine slowly makes its way through the cave system, you notice
  that the four-digit seven-segment displays in your submarine are
  malfunctioning; they must have been damaged during the escape. You'll be in a
  lot of trouble without them, so you'd better figure out what's wrong.

  Each digit of a seven-segment display is rendered by turning on or off any of
  seven segments named `a` through `g`:

  ```text
    0:      1:      2:      3:      4:
   aaaa    ....    aaaa    aaaa    ....
  b    c  .    c  .    c  .    c  b    c
  b    c  .    c  .    c  .    c  b    c
   ....    ....    dddd    dddd    dddd
  e    f  .    f  e    .  .    f  .    f
  e    f  .    f  e    .  .    f  .    f
   gggg    ....    gggg    gggg    ....

    5:      6:      7:     8:      9:
   aaaa    aaaa    aaaa    aaaa    aaaa
  b    .  b    .  .    c  b    c  b    c
  b    .  b    .  .    c  b    c  b    c
   dddd    dddd    ....    dddd    dddd
  .    f  e    f  .    f  e    f  .    f
  .    f  e    f  .    f  e    f  .    f
   gggg    gggg     ....    gggg    gggg
  ```

  So, to render a `1`, only segments `c` and `f` would be turned on; the rest
  would be off. To render a `7`, only segments `a`, `c`, and `f` would be turned
  on.

  The problem is that the signals which control the segments have been mixed up
  on each display. The submarine is still trying to display numbers by producing
  output on signal wires `a` through `g`, but those wires are connected to
  segments randomly. Worse, the wire/segment connections are mixed up separately
  for each four-digit display! (All of the digits within a display use the same
  connections, though.)

  So, you might know that only signal wires b and g are turned on, but that
  doesn't mean segments `b` and `g` are turned on: the only digit that uses two
  segments is `1`, so it must mean segments `c` and `f` are meant to be on. With
  just that information, you still can't tell which wire (`b`/`g`) goes to which
  segment (`c`/`f`). For that, you'll need to collect more information.

  For each display, you watch the changing signals for a while, make a note of
  all ten unique signal patterns you see, and then write down a single four
  digit output value (your puzzle input). Using the signal patterns, you should
  be able to work out which pattern corresponds to which digit.

  For example, here is what you might see in a single entry in your notes:

  ```text
  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
  ```

  (The entry is wrapped here to two lines so it fits; in your notes, it will all
  be on a single line.)

  Each entry consists of ten unique signal patterns, a `|` delimiter, and
  finally the four digit output value. Within an entry, the same wire/segment
  connections are used (but you don't know what the connections actually are).
  The unique signal patterns correspond to the ten different ways the submarine
  tries to render a digit using the current wire/segment connections. Because
  `7` is the only digit that uses three segments, `dab` in the above example
  means that to render a `7`, signal lines `d`, `a`, and `b` are on. Because `4`
  is the only digit that uses four segments, `eafb` means that to render a `4`,
  signal lines `e`, `a`, `f`, and `b` are on.

  Using this information, you should be able to work out which combination of
  signal wires corresponds to each of the ten digits. Then, you can decode the
  four digit output value. Unfortunately, in the above example, all of the
  digits in the output value (cdfeb fcadb cdfeb cdbaf) use five segments and are
  more difficult to deduce.

  For now, focus on the easy digits. Consider this larger example:

  ```text
  be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
  edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
  fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
  fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
  aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
  fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
  dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
  bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
  egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
  gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
  ```

  Because the digits `1`, `4`, `7`, and `8` each use a unique number of
  segments, you should be able to tell which combinations of signals correspond
  to those digits. Counting only digits in the output values (the part after `|`
  on each line), in the above example, there are `26` instances of digits that
  use a unique number of segments (highlighted above).

  In the output values, how many times do digits `1`, `4`, `7`, or `8` appear?
  """
  @spec part_one(String.t()) :: integer()
  def part_one(input) do
    # How long are the signals for 1, 4, 7, and 8?
    desired_lengths =
      [1, 4, 7, 8]
      |> Enum.map(&String.length(Map.get(@correct_segments, &1)))
      |> MapSet.new()

    input
    |> parse_input()
    |> Enum.flat_map(&Map.get(&1, :output))
    |> Enum.filter(&MapSet.member?(desired_lengths, Enum.count(&1)))
    |> Enum.count()
  end

  @doc """
  Through a little deduction, you should now be able to determine the remaining
  digits. Consider again the first example above:

  ```text
  acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
  ```

  After some careful analysis, the mapping between signal wires and segments
  only make sense in the following configuration:

  ```text
   dddd
  e    a
  e    a
   ffff
  g    b
  g    b
   cccc
  ```

  So, the unique signal patterns would correspond to the following digits:

  * `acedgfb`: `8`
  * `cdfbe`: `5`
  * `gcdfa`: `2`
  * `fbcad`: `3`
  * `dab`: `7`
  * `cefabd`: `9`
  * `cdfgeb`: `6`
  * `eafb`: `4`
  * `cagedb`: `0`
  * `ab`: `1`

  Then, the four digits of the output value can be decoded:

  * `cdfeb`: `5`
  * `fcadb`: `3`
  * `cdfeb`: `5`
  * `cdbaf`: `3`

  Therefore, the output value for this entry is `5353`.

  Following this same process for each entry in the second, larger example
  above, the output value of each entry can be determined:

  * `fdgacbe cefdb cefbgd gcbe`: `8394`
  * `fcgedb cgb dgebacf gc`: `9781`
  * `cg cg fdcagb cbg`: `1197`
  * `efabcd cedba gadfec cb`: `9361`
  * `gecf egdcabf bgf bfgea`: `4873`
  * `gebdcfa ecba ca fadegcb`: `8418`
  * `cefg dcbef fcge gbcadfe`: `4548`
  * `ed bcgafe cdgba cbgef`: `1625`
  * `gbdfcae bgc cg cgb`: `8717`
  * `fgae cfgab fg bagce`: `4315`

  Adding all of the output values in this larger example produces `61229`.

  For each entry, determine all of the wire/segment connections and decode the
  four-digit output values. What do you get if you add up all of the output
  values?
  """
  @spec part_two(String.t()) :: integer()
  def part_two(input) do
    input
    |> parse_input()
    |> Enum.map(&translate_output/1)
    |> Enum.sum()
  end

  @spec parse_input(String.t()) :: list(parsed_line_t())
  defp parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_signal_line/1)
  end

  @spec parse_signal_line(String.t()) :: parsed_line_t()
  defp parse_signal_line(line) do
    [signals, output] =
      line
      |> String.split(" | ", trim: true)
      |> Enum.map(&convert_tokens_to_sets/1)

    %{signals: signals, output: output}
  end

  @spec convert_tokens_to_sets(String.t()) :: list(signal_t())
  defp convert_tokens_to_sets(string) do
    string
    |> String.split(" ", trim: true)
    |> Enum.map(&MapSet.new(String.graphemes(&1)))
  end

  @spec translate_output(parsed_line_t()) :: integer()
  defp translate_output(%{signals: signals, output: output}) do
    dictionary = build_dictionary(signals)

    output
    |> Enum.map_join(&Map.get(dictionary, &1))
    |> String.to_integer()
  end

  @spec build_dictionary(list(signal_t())) :: %{
          signal_t() => 0,
          signal_t() => 1,
          signal_t() => 2,
          signal_t() => 3,
          signal_t() => 4,
          signal_t() => 5,
          signal_t() => 6,
          signal_t() => 7,
          signal_t() => 8,
          signal_t() => 9
        }
  defp build_dictionary(signals) do
    derive_by_length = fn length ->
      [signal] = Enum.filter(signals, &(Enum.count(&1) == length))
      signal
    end

    one = derive_by_length.(2)
    four = derive_by_length.(4)

    derive_digit = fn length, common_with_one, common_with_four ->
      [translation] =
        Enum.filter(signals, fn signal ->
          Enum.count(signal) == length and
            Enum.count(MapSet.intersection(signal, one)) == common_with_one and
            Enum.count(MapSet.intersection(signal, four)) == common_with_four
        end)

      translation
    end

    %{
      derive_digit.(6, 2, 3) => 0,
      one => 1,
      derive_digit.(5, 1, 2) => 2,
      derive_digit.(5, 2, 3) => 3,
      four => 4,
      derive_digit.(5, 1, 3) => 5,
      derive_digit.(6, 1, 3) => 6,
      derive_by_length.(3) => 7,
      derive_by_length.(7) => 8,
      derive_digit.(6, 2, 4) => 9
    }
  end
end
