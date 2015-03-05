class UserFormsController < ApplicationController
  def new
    @form = UserForm.new
  end

  def create
    respond_to do |format|
      if request.post?
        @form = UserForm.new(params[:user_form])
        @form.request = request
        if @form.valid?
          lat = @form.latitude.to_i
          lng = @form.longitude.to_i
          (distance = distance_via_helper(lat, lng)) if @form.distance == ''
          distance ||= @form.distance.to_i
          @success = { status: 'ok', distance: distance }
          @error = { status: 'error', distance: distance < 0 ? (distance) : ('-') }

          if 5 >= distance &&  distance >= 0
            format.js { render :json => @success.to_json, content_type: 'application/json' }
            @form.distance = "#{distance} m"
            @form.deliver
          elsif distance > 5
            format.js { render :json => @success.to_json, content_type: 'application/json' }
          else
            format.js { render :json => @error.to_json, content_type: 'application/json' }
          end

        else
          (@error_messages = @form.errors.full_messages) if @form.errors.any?
          if @form.distance.present?
            @error = { status: 'error', distance: @form.distance, error: @error_messages }
          else
            @error = { status: 'error', distance: '-', error: @error_messages }
          end
          format.js { render :json => @error.to_json, content_type: 'application/json' }
        end
      end
    end
  end
end