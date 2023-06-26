class User < ApplicationRecord
  has_many :communities, foreign_key: :owner_id, dependent: :destroy # ユーザーが作成したコミュニティ
  has_many :user_communities, dependent: :destroy
  has_many :membered_communities, through: :user_communities, source: :community  # ユーザーが所属しているコミュニティ
  
  has_many :user_groups, dependent: :destroy
  has_many :membered_groups, through: :user_groups, source: :group  # ユーザーが所属しているグループ
  
  has_many :profiles, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :uid, presence: true, uniqueness: true, length: { maximum: 255 }
  validates :role, presence: true
  validates :is_student, inclusion: { in: [true, false] }
  validates :greeting, length: { maximum: 255 }

  enum role: { general: 0, admin: 1 }

  has_one_attached :avatar

  def self.create_new_user(params, uid)
    is_member = runteq_member?(params[:username])
    user = nil
    begin
      ActiveRecord::Base.transaction do
        user = User.create!(uid: uid, name: params[:username], is_student: is_member)
  
        if is_member
          community = Community.find(1)
          user.take_part_in(community) unless user.membered_communities.include?(community)
        end
      end
  
      return { status: 'success', message: 'User created successfully.', user: user }
    rescue => e
      Rails.logger.error "User creation failed: #{e.message}"
      return { status: 'error', message: 'User creation failed: ' + e.message }
    end
  end
  
  def take_part_in(community)
    membered_communities << community
  end

  def join(group)
    # もしユーザーがすでにこのgroupに所属している場合は、何もしない
    return if self.membered_groups.include?(group)
  
    # もしユーザーが同じコミュニティのグループにすでに所属していたら、そのグループから抜ける
    existing_group = self.user_groups.joins(:group).where(groups: {community_id: group.community_id})
    existing_group.each(&:destroy) if existing_group
  
    # 新たなグループに所属
    self.user_groups.create(group: group)
  end

  private

  def self.runteq_member?(github_user_id)
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    is_member = client.organization_member?('runteq', github_user_id)
    Rails.logger.info "Checked if #{github_user_id} is a member of runteq: #{is_member}"
    is_member
  end
end
