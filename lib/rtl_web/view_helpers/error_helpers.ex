defmodule RTLWeb.ErrorHelpers do
  use Phoenix.HTML

  def error_tag(form, field) do
    case form.errors[field] do
      {message, _metadata} ->
        content_tag(:span, raw("#{field} #{message}"), class: "formField__error")

      # Can also use translate_error(error) for i18n

      _ ->
        nil
    end
  end

  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file.
    # Ecto will pass the :count keyword if the error message is
    # meant to be pluralized.
    # On your own code and templates, depending on whether you
    # need the message to be pluralized or not, this could be
    # written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count
    #     dgettext "errors", "is invalid"
    #
    if count = opts[:count] do
      Gettext.dngettext(RTL.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(RTL.Gettext, "errors", msg, opts)
    end
  end
end
