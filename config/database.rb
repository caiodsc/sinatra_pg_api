configure :test do
  set :database, {
      adapter: 'postgresql',
      encoding: 'utf8',
      database: 'aprovacao_test',
      pool: 5,
      username: 'postgres',
      host: 'postgres'
  }
end

configure :development do
  set :database, {
      adapter: 'postgresql',
      encoding: 'utf8',
      database: 'aprovacao_development',
      pool: 5,
      username: 'postgres',
      password: 'bemol100',
  }
end

configure :production do
  db = URI.parse(ENV['DATABASE_URL'] || 'postgres:///postgres/aprovacao_production')

  set :database, {
      adapter:  db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      host:     db.host,
      username: db.user,
      password: db.password,
      database: db.path[1..-1],
      encoding: 'utf8'
  }
end