class AttachmentsController < ApplicationController

  def show
    asset = Asset.find(params[:id])
    # do security check here
    send_file asset.data.path, :type => asset.data_content_type, :disposition => 'asset', :x_sendfile => true
  end

end
