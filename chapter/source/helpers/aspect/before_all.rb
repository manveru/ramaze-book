require 'ramaze'

class AdminController < Ramaze::Controller
  def create_user(name)
    # ...
  end

  def delete_user(name)
    # ...
  end

  before_all{ redirect_referrer unless user_is_root? }

  private

  def user_is_root?
    session[:user_is_root]
  end
end

Ramaze.start
