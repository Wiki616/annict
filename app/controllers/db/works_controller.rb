class Db::WorksController < Db::ApplicationController
  permits :season_id, :sc_tid, :title, :media, :official_site_url, :wikipedia_url,
          :released_at, :released_at_about, :twitter_username,
          :twitter_hashtag, :fetch_syobocal

  before_action :load_works, only: [:index, :season, :resourceless, :search]
  before_action :set_work, only: [:show, :edit, :update, :destroy]


  def index(page: nil)
    @works = @all_works.order("released_at DESC NULLS LAST").page(page)
  end

  def season(page: nil, slug: ENV["ANNICT_CURRENT_SEASON"])
    @works = case slug
             when ENV["ANNICT_CURRENT_SEASON"] then @current_season_works
             when ENV["ANNICT_NEXT_SEASON"] then @next_season_works
             when ENV["ANNICT_PREVIOUS_SEASON"] then @previous_season_works
             end
    @works = @works.order("released_at DESC NULLS LAST").page(page)
    render :index
  end

  def resourceless(page: nil, name: "episode")
    @works = case name
             when "episode" then @episodeless_works
             when "item" then @itemless_works
             end
    @works = @works.order("released_at DESC NULLS LAST").page(page)
    render :index
  end

  def search(page: nil, q: "")
    @works = Work.where("lower(title) LIKE ?", "%#{q}%")
                 .order("released_at DESC NULLS LAST")
                 .page(page)
    render :index
  end

  def new
    @work = Work.new
  end

  def create(work)
    @work = Work.new(work)

    if @work.save
      redirect_to edit_db_work_path(@work), notice: "作品を登録しました"
    else
      render :new
    end
  end

  def update(work)
    if @work.update_attributes(work)
      redirect_to edit_db_work_path(@work), notice: "作品を更新しました"
    else
      render :edit
    end
  end

  def destroy
    @work.destroy
    redirect_to marie_works_path, notice: '作品を削除しました'
  end

  private

  def set_work
    @work = Work.find(params[:id])
  end

  def load_works
    @all_works = Work.all
    @current_season_works = Work.by_season(ENV["ANNICT_CURRENT_SEASON"])
    @next_season_works = Work.by_season(ENV["ANNICT_NEXT_SEASON"])
    @previous_season_works = Work.by_season(ENV["ANNICT_PREVIOUS_SEASON"])
    @episodeless_works = Work.where(episodes_count: 0)
    @itemless_works = Work.where(items_count: 0)
  end
end
