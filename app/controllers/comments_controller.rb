class CommentsController < ApplicationController
  before_action :login_required, :no_locked_required
  before_action :find_comment, only: [:edit, :cancel, :update, :trash]

  def create
    resource, id = request.path.split('/')[1, 2]
    @commentable = resource.singularize.classify.constantize.find(id)
    @comment = @commentable.comments.new params.require(:comment).permit(:body).merge(user: current_user)
    if @comment.save
      @comment.delay.notify
    end
  end

  def edit
  end

  def cancel
  end

  def update
    @comment.update_attributes params.require(:comment).permit(:body)
  end

  def trash
    @comment.trash
  end

  private

  def find_comment
    @comment = current_user.comments.fetch params[:id]
  end
end
