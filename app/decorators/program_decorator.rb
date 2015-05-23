class ProgramDecorator < Draper::Decorator
  delegate_all

  def to_diffable_resource
    hash = {}

    hash["channel_id"] = {
      data: object.channel_id,
      value: object.channel.name
    }

    episode_path = h.work_episode_path(object.episode.work, object.episode)
    episode_title = object.episode.decorate.title_with_number
    hash["episode_id"] = {
      data: object.episode_id,
      value: h.link_to(episode_title, episode_path, target: "_blank")
    }

    hash["started_at"] ={
      data: object.started_at.to_time.strftime("%Y/%m/%d %H:%M"),
      value: object.started_at.to_time.strftime("%Y/%m/%d %H:%M")
    }

    hash
  end
end
