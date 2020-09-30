use Bootleg.DSL

role :build, "10.42.0.1", silently_accept_hosts: true, user: "build", workspace: "/home/build/workspace"
role :app, "10.42.0.1", silently_accept_hosts: true, user: "hab", workspace: "/home/hab/habctl"

config :refspec, "main"

task :phx_digest do
  remote :build, cd: "assets" do
    "npm install"
    "npm run deploy"
  end
  remote :build do
    "MIX_ENV=prod mix phx.digest"
  end
end

after_task :compile, :phx_digest
