class Admin::UsersController < Admin::Base
  def index
    @users = User.order(:id)
  end
end
