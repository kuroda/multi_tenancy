class UsersController < ApplicationController
  def index
    # ActiveRecord::Base.execute("")

    @users = User.order(:id)
  end
end
