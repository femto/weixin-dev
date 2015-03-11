class AdminConstraint
  def self.matches?(request)
    if request.session[:user_id]
      user = User.find request.session[:user_id]
      user && user.admin?
    end
  end
end
