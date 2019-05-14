# Pending feature: Admin can download script to split video into segments

As an admin, I can currently download each whole video individually. But I'd also like support for downloading or generating all _tagged clips_ I've coded.

I worked out how to do this as MVP. The plan will be:

  * On the manage videos list, admin can checkmark-select videos they want to cut
  * At the top of the page, select Batch actions -> Download script to cut clips
  * This downloads a json(ish) file that defines each clip's source video filename, start TS, and end TS. Comments at the top should document how to use it & what you'll need.
  * The admin downloads all selected videos and puts them in a folder along with the manifest.
  * Admin downloads a static script (maybe the manifest comments point to where you can get it) that knows how to cut each video into clips.
  * Admin runs the script, pointing it to the target folder. The script processes each line of the json, finding that video file and generating a clip that's written in a subfolder, named the video name plus tag plus abbreviated timestamps. Script offers friendly error msgs if invoked wrong, or if required tools aren't installed, or if the manifest or a required video file can't be found.
  * Advice on how to cut a video clip using ffmpeg: https://superuser.com/a/458804/233455
  * After the script completes, there's a subfolder containing each clip, named based on the parent video, the tag, and the start & end timestamps.


## Code snippets I'll probably use

"Batch actions" dropdown, at the top of the manage videos list:

```
  <div class="pb-3">
    <div class="dropdown">
      <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="video-batch-actions" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">Batch actions</button>
      <div class="dropdown-menu" aria-labelledby="video-batch-actions">
        <a href="#" class="dropdown-item js-download-segmenter-script" data-project-uuid="<%= @project.uuid %>">Download script to create segments</a>
      </div>
    </div>
  </div>
```

The checkbox in the videos list:

```
  <td style="padding: 0px">
    <label style="display: block; width: 50px; height: 80px; padding: 20px;">
      <input type="checkbox" class="js-select-video form-check" data-video-id="<%= video.id %>" name="select_video" value="1" style="">
    </label>
  </td>
```

JS for selecting rows in the videos list, and for requesting the clips manifest download:

```
  $(document).on("click", ".js-select-video", function(){
    let row = $(this).parents("tr")
    row.toggleClass("u-selected-row")
  })

  $(document).on("click", ".js-download-segmenter-script", function(e){
    e.preventDefault()
    let projectUuid = $(this).data("project-uuid")
    let selected = $(".js-select-video:checked")
    if (selected.length > 0) {
      window.location = "/manage/projects/"+projectUuid+"/videos/clips_manifest?video_ids=1,2,3"
    } else {
      alert("Please select one or more videos below first.")
    }
  })
```

Style for highlighting selected rows:

```
tr.u-selected-row { th, td { background-color: #cef; } }
```

Controller action for downloading the manifest:

```
  def clips_manifest(conn, %{"video_ids" => video_ids}) do
    video_ids = String.split(video_ids, ",")
    videos = Videos.
    send_download conn, {:binary, "Test content"}, filename: "video_clips_manifest.json"
  end
```
