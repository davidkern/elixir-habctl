use Bootleg.DSL

role :build, "10.42.0.1", silently_accept_hosts: true, user: "build", workspace: "/home/build/workspace"
role :app, "10.42.0.1", silently_accept_hosts: true, user: "hab", workspace: "/home/hab/habctl"
