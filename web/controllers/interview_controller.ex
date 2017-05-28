defmodule Zb.InterviewController do
  use Zb.Web, :controller
  alias Zb.{Interview, TaskComputer}

  plug :require_user
  plug :scrub_params, "interview" when action in [:update]

  def edit(conn, %{"id" => id}) do
    interview = load_interview(conn, id)
    changeset = Interview.interviewee_changeset(interview, %{})
    render conn, "edit.html", interview: interview, changeset: changeset,
      presigned_s3_url: presigned_s3_url(interview)
  end

  def update(conn, %{"id" => id, "interview" => interview_params}) do
    interview = load_interview(conn, id)
    changeset = Interview.interviewee_changeset(interview, interview_params)
    Repo.update!(changeset) # The interface should prevent invalid data submissions.
    conn
      |> put_flash(:info, "Great, your interview has been submitted!")
      |> redirect(to: interview_path(conn, :done))
  end

  def done(conn, _) do
    render conn, "done.html", next_task: List.first(TaskComputer.all_incomplete_tasks(conn.assigns.current_user))
  end

  # === Helpers ===

  defp load_interview(conn, id) do
    Interview
      |> Interview.by(conn.assigns.current_user)
      |> Interview.incomplete
      |> Repo.get!(id)
      |> Repo.preload(:question)
  end

  defp presigned_s3_url(interview) do
    bucket = System.get_env("S3_BUCKET")
    path = Zb.Recording.s3_path(interview)
    # The ACL doesn't appear to have much effect. Instead I set up a Bucket Policy
    # to make all contents readable to the public.
    {:ok, url} = ExAws.S3.presigned_url(ExAws.Config.new(:s3), :put, bucket, path, query_params: [{"ACL", "public-read"}, {"contentType", "binary/octet-stream"}])
    url
  end
end
