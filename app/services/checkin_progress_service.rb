class CheckinProgressService
  attr_reader :user, :work, :episode_ids, :checked_episode_ids, :all_checkins_count

  def initialize(user, work)
    @user = user
    @work = work
    @episode_ids = work.episodes.pluck(:id)
    @checked_episode_ids = user.checkins.where(work: work).pluck(:episode_id)
    @all_checkins_count = get_all_checkins_count(checked_episode_ids)
  end

  # 指定した作品の視聴が何周目かを返す
  def episodes_round
    count = episode_ids.count * all_checkins_count

    if checked_episode_ids.count > count
      all_checkins_count + 1
    elsif checked_episode_ids.count == count
      all_checkins_count
    else
      0
    end
  end

  def halfway_checked_count
    ids = checked_episode_ids

    if all_checked? && over_checkin?
      all_checkins_count.times do
        ids = remove_checked_episode_id(ids)
      end

      return ids.uniq.count
    end

    (episode_ids & ids).count
  end

  def ratio
    (halfway_checked_count / work.episodes.count.to_f rescue 1) * 100
  end

  private

  # 何周見たかを返す
  def get_all_checkins_count(checked_episode_ids, count = 0)
    unchecked_episode_ids = episode_ids - checked_episode_ids

    return count if unchecked_episode_ids.present?

    if checked_episode_ids.present?
      ids = remove_checked_episode_id(checked_episode_ids)
      get_all_checkins_count(ids, count + 1)
    else
      count
    end
  end

  # 全てのエピソードにチェックインしているかどうか
  def all_checked?
    episode_ids.count == (episode_ids & checked_episode_ids).count
  end

  # 全てのエピソードにチェックインした上で、さらに何本かのエピソードにチェックインしているかどうか
  def over_checkin?
    checked_episode_ids.count > episode_ids.count * all_checkins_count
  end

  def remove_checked_episode_id(checked_episode_ids)
    ids = checked_episode_ids.dup

    episode_ids.each do |eid|
      i = ids.index(eid)
      ids.delete_at(i) if i.present?
    end

    ids
  end
end
