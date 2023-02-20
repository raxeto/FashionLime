class Admin::TradeMarksController < AdminController

  def index
    @trade_marks = TradeMark.all
  end

  def new
      @trade_mark = TradeMark.new
  end

  def edit
    @trade_mark = TradeMark.find(params[:id])
  end

  def update
      trade_mark = TradeMark.find(params[:id])
      
      unless trade_mark.update_attributes(trade_mark_params)
        render :edit
        return
      end
      redirect_to admin_trade_marks_path, notice: 'TradeMark edited successfully.'
    end

  def create
    trade_mark = TradeMark.new(trade_mark_params)
    unless trade_mark.save
        render :new
        return
    end
    redirect_to admin_trade_marks_path, notice: 'TradeMark created successfully!'
  end

  def destroy
    
    if TradeMark.destroy(params[:id])
      redirect_to admin_trade_marks_path, notice: 'TradeMark destroyed successfully!'
    else 
      redirect_to admin_trade_marks_path, alert: 'TradeMark was not destroyed!'
    end

  end

  private

  def trade_mark_params
    params.require(:trade_mark).permit(:name, :key, :logo)
  end


end
