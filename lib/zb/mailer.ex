# This boilerplate module is needed to enable email sending.
# See https://hexdocs.pm/bamboo/0.7.0/readme.html
defmodule Zb.Mailer do
  use Bamboo.Mailer, otp_app: :zb
end
