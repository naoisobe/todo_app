class TodosController < ApplicationController
  before_action :set_todo, only: %i[edit update destroy]

  def index
    @todos = Todo.order(created_at: :desc)
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      respond_to do |format|
        format.turbo_stream { render :create }
        format.html { redirect_to root_path, notice: "Todo created" }
      end
    else
      @todos = Todo.order(created_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream {
        if params[:cancel]
          render :cancel_edit
        else
          render :edit
        end
      }
      format.html { redirect_to root_path }
    end
  end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to root_path }
      end
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @todo.destroy
    respond_to do |format|
      format.turbo_stream { render :destroy }
      format.html { redirect_to root_path }
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end
end
