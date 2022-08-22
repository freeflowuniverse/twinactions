module websocket

type Any = int | string | bool

// type Workload = Machine | K8s 

// enum QType {
//   form string = "zmachine"
//   input
//   menu
//   yn
//   data
//   choice
// }

// struct Answer {
  // qid string
// }

struct QAnswer {
// answer Answer
  symbol string
  value string
}

struct MachineSpecs {
  vm_name string
  memory int
  root_fs int
  cpu int
  flist string
  entrypoint string
  env string
  public_ip bool
  planetary_ip bool
}


pub struct QTypes {
pub:
  form string = "form"
  input string = "input"
  menu string = "menu"
  yn string = "yn"
  data string = "data"
  choices string = "choices"
}

pub const q_types = QTypes{}

type QType = string

struct Choice {
  value Any
  title string
}

struct QuestionInput {
  q_type QType
  id int
  question string
  descr string
  returntype string
  regex string
  regex_errormsg string
  min int
  max int
  sign bool
  symbol string

  answer Any
}

struct QuestionYn {
  q_type QType
  chat_id string
  question string
  id int
  symbol string

  answer Any
}

struct QuestionChoice {
  q_type QType
  question string
  id int
  descr string
  sorted bool
  choices []Choice
  multi bool
  sign bool
  symbol string

  answer Any
}

struct QuestionDropdown {
  q_type QType
  question string
  id int
  descr string
  sorted bool
  choices []Choice
  multi bool
  sign bool
  symbol string

  answer Any
}

struct QuestionDate {
  q_type QType
  id int
  question string
  symbol string

  answer Any
}

struct Form {
  q_type QType
  question string
  chat_id string
  id int
  description string
  form []Questions
  sign bool
}

type Questions = QuestionInput | QuestionYn | QuestionChoice | QuestionDropdown | QuestionDate