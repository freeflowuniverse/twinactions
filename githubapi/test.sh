gh api graphql -f query='
    query{
        user(login: "despiegk"){
            projectV2(number: 1) {
                id
            }
        }
    }
  '