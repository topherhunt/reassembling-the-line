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


## Troubleshooting

If integration tests fail with a ChromeDriver error "unknown error: call function result missing 'value'", you're likely running an outdated version of ChromeDriver. Verify that `chromedriver --version` returns the latest version available in https://sites.google.com/a/chromium.org/chromedriver.

