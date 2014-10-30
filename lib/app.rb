require 'idea_box'
require './lib/idea_box/my_uploader'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  configure :development do
    register Sinatra::Reloader
  end

  not_found do
    haml :error
  end

  get '/' do
    haml :index, locals: {ideas: IdeaStore.all, idea: Idea.new(params)}
  end
  # {"idea"=>{"title"=>"asdf", "description"=>"asdf", "resource"=>"asdf",
  # "image"=>{:filename=>"IMG_1440.JPG", :type=>"image/jpeg", :name=>"idea[image]", :tempfile=>#<, :head=>"Content-Disposition: form-data; name=\"idea[image]\"; filename=\"IMG_1440.JPG\"\r\nContent-Type: image/jpeg\r\n"}}}
# {"idea"=>{"title"=>"asdf", "description"=>"asdf", "resource"=>"asdf"}}
  post '/' do
    idea_params = params["idea"]
    if params["idea"]["image"]
      MyUploader.new.store!(params['idea']['image'])
      filename = params['idea']['image'][:filename]
      idea_params.merge!({"image" => filename})
    end
    IdeaStore.create(idea_params)
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    haml :edit, locals: {idea: idea}
  end

  put '/:id' do |id|
    idea_params = params["idea"]
    if params["idea"]["image"]
      MyUploader.new.store!(params['idea']['image'])
      filename = params['idea']['image'][:filename]
      idea_params.merge!({"image" => filename})
    end
    IdeaStore.update(id.to_i, idea_params)
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  get '/' do
    haml :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new(params)}
  end

  get '/:id' do |id|
    haml :show, locals: {idea: IdeaStore.find(id.to_i)}
  end

  def handle_image_upload(params)
  end

end
