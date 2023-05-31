# ColumnTaxInterview - The Challenge

Welcome to our engineering challenge!

The Challenge
Column Tax is a software company built to make taxes and accounting easier for every American. This engineering task is centered around a firm that was too creative with its accounting practices.

As you may know, Enron was an American organization that committed massive accounting fraud. And their accounting firm, Arthur Andersen, was effectively dissolved. As a result, Enron’s entire email corpus was released to the public.

The legal team suing Enron needs your help. They need to search through the email corpus from their mobile phone to reference material. A few interesting restrictions:
This will be running in a mobile environment, so we don't have a lot of memory. You can't just load everything into RAM. You need to be as efficient as possible about organizing the data on disk, keeping as little data as possible in memory.
We don't have access to the Internet. The entire corpus will live on the device.
You do have access to a server if you want to pre-process the data somehow before placing on the device. But once it's on their phone, it's there forever.
Because typing on a phone is annoying, we want results to appear as you type. For example, if I type "app", I'd see emails matching on "app", "apple" and "application".
You don't have to build an app or any UI. We're just looking for a method that we can call — e.g. search(term) — that can return results. We don’t actually need to do anything in “real-time”, but just create the method that we would call on each keystroke.
You can use any programming language you’d like!
Please implement a solution yourself. Don't use a library (e.g. install Lucene).
The dataset is here. Start the download now. While it's going, you can check out a sample from it here.

Evaluation Criteria
We will be evaluating your submission based on the following criteria:
Completion - Is the project finished?
Design - Does the code use appropriate data structures and algorithms?
Functionality - Does the application work well for the intended user?
Maintainability - Is the code documented? Easy to follow? Are the APIs well designed?
Logistics
The total time allotted is three hours.

## Some initial thoughts

- Seems reasonable to split up the searching so you can search _just_ the contacts and _just_ the calendar, or _just_ emails,
- Looks like there might be a lot of duplication? eg a folder called "all documents"... Cleaning that up could be a good idea.
- In truth I'd probably put this into SQL lite DB, though haven't used it much, so for now I might just stick to searching files. But the db might give us a change to de-duplicate things more easily (if we can put strategic unique indexes).
- We can stream to search the files, reducing the memory impact.
- Search as we type means the first few chars will get a LOT of results. We can debounce - so we wait for more input before searching, or we can paginate. In truth you might want both.

### Deduplication

Not sure if we can trust that all files have different file names, will we see the same files in a different folder? We might have to hash the file contents to deduplicate - being wary of collisions of course.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `column_tax_interview` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:column_tax_interview, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/column_tax_interview>.

