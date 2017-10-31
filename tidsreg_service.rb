require 'HTTParty'
require 'json'

class TidsregService
  include HTTParty
  base_uri 'https://tidsreg.trifork.com'
  #debug_output

  def initialize(username, password)
    @username = username
    response = self.class.post(
        '/api/auth/login',
        body: {
            username: username,
            password: password
        },
        headers:{
            'Content-Type' => 'application/x-www-form-urlencoded'
        }
    )
    @cookie = response.headers['set-cookie']
    @cookie.slice! 'path=/; HttpOnly,'

    @ids = {
        :childs_first_sickday => 2064,
        :vacation => 2061,
        :hollyday => 49707,
        :sick => 2062,
        :internal_time => 2058
    }
  end

  def account
    self.class.get('/api/auth', headers: {'Cookie' => @cookie})
  end

  def hours date, days
    response = self.class.get("/api/Hours/#{date.strftime('%d-%m-%Y')}?days=#{days}", headers: {'Cookie' => @cookie, 'Content-Type' => 'application/x-www-form-urlencoded'})
    json = JSON.parse(response.body)

    json = json['TimeRegistrations'].group_by{|entry|
      Date.parse(entry['Date'])
    }

    json.each{|date, data|

      entry = {}
      @ids.each{|key, id|
         entry[key] = data.reduce(0){|sum, d|
           if d['ActivityId'] == id
             sum += d['Hours']
           end
           sum
        }
      }

      entry[:project] = data.select{|d|
        !@ids.values.include? d['ActivityId']
      }.reduce(0){|sum, d|
        sum + d['Hours']
      }
      json[date] = entry
    }
  end
end