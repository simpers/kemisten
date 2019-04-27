use Mix.Releases.Config,
  default_release: :kemisten,
  default_environment: Mix.env

environment :dev do
  set dev_mode: true 
  set include_erts: false
  set include_system_libs: false
  set cookie: :kemisten_devster
end

environment :prod do
  set include_erts: true
  set include_system_libs: true
  set cookie: :kemisten_prodster
end

release :kemisten do
  set version: current_version(:kemisten)
  set applications: [
    :slack,
    :jason
  ]
end
