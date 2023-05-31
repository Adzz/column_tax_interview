defmodule ColumnTaxInterview do
  @moduledoc """
  Documentation for `ColumnTaxInterview`.
  """
  require Logger

  @email_body_db_path "email_body_db.txt"

  @doc """
  """
  def search_the_bodies(term) do
    search_chars = String.codepoints(term)
    {:ok, file} = File.open(@email_body_db_path, [])

    {_, results, _} =
      IO.stream(file, :line)
      |> Enum.reduce({"", [], search_chars}, fn
        # When we get here we need to flush the buffer essentially. We need to be like
        # Did we find all of the search terms? If so add to matches, otherwise don't do that
        "# :email_body_found_in: " <> file_path,
        {current_email, email_matches, search_terms_remaining} ->
          {file_path, email_matches, search_chars}

        line, {current_email, email_matches, search_terms_remaining} ->
          # The tricky part is that the search term might wrap onto the next line...
          case search_line(line, search_terms_remaining, search_chars) do
            # Here we found a match on the line.
            [] ->
              {current_email, [current_email | email_matches], search_chars}

            terms_remaining_after_line_search ->
              {current_email, email_matches, terms_remaining_after_line_search}
          end
      end)

    File.close(file)
    results
  end

  defp search_line(_, [], _), do: []

  defp search_line(<<>>, search_terms_remaining, _) do
    search_terms_remaining
  end

  defp search_line(<<char::binary-size(1), restline::binary>>, [first_term | rest], search_chars) do
    if char == first_term do
      search_line(restline, rest, search_chars)
    else
      # Asd soon as we don't match we want to reset to us the whole search term again.
      # This doesn't do that if we get part way through it only undoes one.
      search_line(restline, search_chars, search_chars)
    end
  end

  def pre_process_email_bodies() do
    root = Path.expand(".")

    File.ls!(root <> "/maildir")
    |> Enum.each(fn folder ->
      {:ok, file} = File.open(@email_body_db_path, [:append])
      find_all_files(root <> "/maildir/" <> folder, file)
      File.close(file)
    end)
  end

  def find_all_files(root, destination) do
    case File.ls(root <> "/") do
      {:ok, folders} ->
        Enum.each(folders, fn folder ->
          find_all_files(root <> "/#{folder}", destination)
        end)

      {:error, :enotdir} ->
        body =
          File.read!(root)
          |> String.split("\n", trim: true)
          |> parse_email_body()

        case body do
          {:error, :no_body_found} ->
            Logger.error("no email body found in #{root}")

          body ->
            # We could append metadata here to make it clear which email file this was.
            #
            IO.write(destination, ["\nemail_body_found_in: #{root}\n" | body])
        end
    end
  end

  defp parse_email_body([]) do
    {:error, :no_body_found}
  end

  defp parse_email_body(["X-FileName:" <> _rest_of_line | body]) do
    body
  end

  defp parse_email_body([_ | rest]) do
    parse_email_body(rest)
  end

  # This proved to not be useful!
  defp check_if_duplicate(file_path, files_seen) do
    hash = hash_file(file_path)

    if Map.get(files_seen, hash, false) do
      Logger.error("Duplicate file found!!")
      files_seen
    else
      Map.put(files_seen, hash, true)
    end
  end

  defp hash_file(file_path) do
    initial_hash_state = :crypto.hash_init(:sha256)

    # 2048 is essentially randomly chosen, could be tuned later....
    File.stream!(file_path, [], 2048)
    |> Enum.reduce(initial_hash_state, fn chunk, acc ->
      :crypto.hash_update(acc, chunk)
    end)
    |> :crypto.hash_final()
    |> Base.encode64()
  end
end
