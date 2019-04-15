# Testing


## Manual integration test script

First, run:

    mix run priv/repo/reseed.exs

- Log in as admin
- Go to the "Code videos" list
- Delete a video
- Code a video
- Edit a coded video
  - The existing tags show up as expected
  - Your changes are saved
