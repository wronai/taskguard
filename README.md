# 🎯 LLM Task Controller - Best Practices Guide

## 🚀 Quick Setup

```bash
# Download and setup
curl -o llmtask.py https://your-repo.com/llmtask.py
chmod +x llmtask.py

# Initialize (creates .llmcontrol.yaml and TODO.yaml)
python3 llmtask.py

# Activate task management
source ~/.llmtask_shell.sh
```

## 📋 Configuration (.llmcontrol.yaml)

### 🎯 Focus Control
```yaml
focus:
  max_files_per_task: 3           # Limit files per task
  max_lines_per_file: 200         # Prevent huge files
  require_todo_completion: true    # Must complete current task first
  auto_changelog: true            # Auto-update changelog
  task_timeout_minutes: 30        # Force task completion
```

### 📚 Best Practices Selection
```yaml
best_practices:
  python:
    enforce_docstrings: true      # Require function documentation
    enforce_type_hints: true      # Require type annotations
    max_function_length: 50       # Max lines per function
    require_tests: true           # Require test files
    naming_convention: snake_case # Enforce naming style
    imports_organization: true    # Organize imports
    
  javascript:
    enforce_jsdoc: true           # Require JSDoc comments
    prefer_const: true            # Prefer const over let
    max_function_length: 30       # Shorter JS functions
    require_error_handling: true  # Must handle errors
    naming_convention: camelCase  # JS naming style
    
  general:
    single_responsibility: true   # One purpose per function
    descriptive_names: true       # No single-letter vars
    no_hardcoded_values: true     # Use constants/config
    consistent_formatting: true   # Follow style guide
    meaningful_comments: true     # Explain why, not what
```

### 📊 Quality Gates
```yaml
quality_gates:
  syntax_check: true             # Check syntax before execution
  security_scan: true            # Scan for security issues
  style_check: true              # Enforce coding style
  test_coverage: 80              # Minimum test coverage %
  complexity_limit: 10           # Max cyclomatic complexity
```

## 🎪 LLM Workflow Examples

### ✅ Perfect Focused Session:
```bash
# LLM starts session
show_tasks
# 📋 Current Tasks:
# ⏳ #1 🔴 [feature] Setup project structure
# ⏳ #2 🔴 [feature] Implement core functionality

# LLM picks a task
start_task 1
# 🎯 Started task: Setup project structure
# 📝 Subtasks:
#    - Create main directories
#    - Setup configuration files  
#    - Initialize version control

# LLM works on ONLY this task
mkdir src tests docs
touch src/__init__.py src/main.py
python src/main.py
# ✅ python src/main.py completed safely
# ✅ Code follows best practices!

# LLM completes task
complete_task
# ✅ Task completed: Setup project structure
# 📝 Changelog updated with: Setup project structure
# 🎯 Next suggested task: Implement core functionality

# LLM automatically moves to next task
start_task 2
# 🎯 Started task: Implement core functionality
```

### 🚨 LLM Tries to Lose Focus:
```bash
# LLM has active task but tries to create many files
start_task 1
# 🎯 Started task: Setup project structure

# LLM tries to work on multiple things
touch file1.py file2.py file3.py file4.py
# 🎯 Focus! Complete current task first: Setup project structure
# 📊 Files modified today: 3/3

# LLM tries to start another task without completing current
start_task 2
# 🎯 Focus! Complete current task first: Setup project structure

# LLM is forced to complete current task
complete_task
# ✅ Task completed: Setup project structure
```

### 📋 Best Practice Enforcement:
```python
# LLM creates bad code
def process_data(data):
    return data.split(',')
```

```bash
python bad_code.py
# 📋 Best Practice Reminders:
#    - Missing docstrings in functions
#    - Missing type hints in functions
#    - Use more descriptive variable names
```

```python
# LLM fixes code
def process_csv_data(csv_string: str) -> List[str]:
    """
    Process CSV string and return list of values.
    
    Args:
        csv_string: Input CSV string to process
        
    Returns:
        List of individual CSV values
    """
    return csv_string.split(',')
```

```bash
python good_code.py
# ✅ Code follows all best practices!
```

## 📋 Best Practices Library

### 🐍 Python Best Practices
```yaml
python:
  # Code Structure
  enforce_docstrings: true
  enforce_type_hints: true
  max_function_length: 50
  max_class_length: 200
  
  # Naming Conventions
  naming_convention: snake_case
  constant_naming: UPPER_SNAKE_CASE
  class_naming: PascalCase
  
  # Code Quality
  require_tests: true
  test_coverage_minimum: 80
  imports_organization: true
  no_unused_imports: true
  
  # Security & Safety
  no_eval_exec: true
  no_shell_injection: true
  validate_inputs: true
  handle_exceptions: true
```

### 🌐 JavaScript/TypeScript Best Practices
```yaml
javascript:
  # Code Structure
  enforce_jsdoc: true
  max_function_length: 30
  prefer_arrow_functions: true
  
  # Variables & Constants
  prefer_const: true
  no_var_declaration: true
  destructuring_preferred: true
  
  # Error Handling
  require_error_handling: true
  no_silent_catch: true
  promise_error_handling: true
  
  # Modern JS
  prefer_template_literals: true
  prefer_spread_operator: true
  async_await_over_promises: true
```

### 🛢️ Database Best Practices
```yaml
database:
  # SQL Safety
  no_sql_injection: true
  use_parameterized_queries: true
  validate_before_query: true
  
  # Performance
  use_indexes: true
  limit_query_results: true
  avoid_n_plus_one: true
  
  # Transactions
  use_transactions: true
  handle_rollbacks: true
  connection_pooling: true
```

### 🔐 Security Best Practices
```yaml
security:
  # Input Validation
  validate_all_inputs: true
  sanitize_user_data: true
  check_file_uploads: true
  
  # Authentication
  strong_password_policy: true
  secure_session_management: true
  implement_rate_limiting: true
  
  # Data Protection
  encrypt_sensitive_data: true
  secure_api_endpoints: true
  log_security_events: true
```

### 🎨 UI/UX Best Practices
```yaml
frontend:
  # Accessibility
  semantic_html: true
  aria_labels: true
  keyboard_navigation: true
  screen_reader_support: true
  
  # Performance
  optimize_images: true
  minimize_bundle_size: true
  lazy_loading: true
  
  # User Experience
  responsive_design: true
  loading_states: true
  error_feedback: true
  consistent_styling: true
```

## 🎯 Task Management Patterns

### 📝 TODO.yaml Structure
```yaml
# 🎯 Project TODO List

- id: 1
  title: "Setup project structure"
  category: "feature"
  priority: "high"
  status: "pending"
  estimated_hours: 2
  description: "Create basic project structure with proper organization"
  subtasks:
    - "Create main directories"
    - "Setup configuration files"
    - "Initialize version control"
  labels: ["setup", "foundation"]

- id: 2
  title: "Implement authentication system"
  category: "feature"
  priority: "high"
  status: "pending"
  estimated_hours: 8
  description: "Build secure user authentication with JWT tokens"
  subtasks:
    - "Create user model"
    - "Implement login/register endpoints"
    - "Add JWT token management"
    - "Create auth middleware"
  dependencies: [1]
  labels: ["auth", "security"]

- id: 3
  title: "Fix user input validation"
  category: "bugfix"
  priority: "medium"
  status: "pending"
  estimated_hours: 3
  description: "Add proper validation for all user inputs"
  labels: ["validation", "security"]

- id: 4
  title: "Refactor database queries"
  category: "refactor"
  priority: "low"
  status: "pending"
  estimated_hours: 5
  description: "Optimize slow database queries for better performance"
  labels: ["performance", "database"]

- id: 5
  title: "Add unit tests for auth module"
  category: "test"
  priority: "medium"
  status: "pending"
  estimated_hours: 4
  description: "Write comprehensive tests for authentication system"
  dependencies: [2]
  labels: ["testing", "auth"]
```

### 📊 Task Categories & Priorities
```yaml
todo_management:
  categories:
    - feature     # New functionality
    - bugfix      # Fix existing issues
    - refactor    # Improve existing code
    - test        # Add/update tests
    - docs        # Documentation updates
    - chore       # Maintenance tasks
    - security    # Security improvements
    - performance # Performance optimizations
  
  priorities:
    - critical    # Must fix immediately
    - high        # Important, do soon
    - medium      # Normal priority
    - low         # Nice to have
    - backlog     # Future consideration
  
  auto_create_subtasks: true
  require_estimation: true
  track_time: true
  dependency_management: true
```

## 🚀 Command Reference

### 📋 Task Management
```bash
show_tasks              # List all tasks with status
start_task <id>         # Start working on specific task
complete_task           # Mark current task as done
add_task "<title>" [category] [priority]  # Add new task

# Examples:
add_task "Add user authentication" feature high
add_task "Fix login bug" bugfix critical
start_task 1
complete_task
```

### 🎯 Focus Control
```bash
focus_status           # Check current focus metrics
productivity           # Show productivity statistics

# Example output:
focus_status
# 🎯 Focus Status:
# Current Task: Setup project structure
# Focus Score: 95/100
# Files Modified Today: 2/3
# Time Remaining: 25m 30s
```

### 📚 Best Practices
```bash
best_practices [file]   # Check file against best practices
best_practices         # Show all available practices

# Example:
best_practices auth.py
# 📋 Best Practice Review for auth.py:
#    ❌ Missing docstrings in functions
#    ❌ Missing type hints in functions
#    ✅ Proper error handling found
```

### ⚙️ Configuration
```bash
config                 # Show current configuration
config edit           # Edit configuration file
```

## 🎨 Customization Examples

### 🔧 Team-Specific Practices
```yaml
# .llmcontrol.yaml for Django team
best_practices:
  python:
    django_specific:
      use_django_forms: true
      follow_model_conventions: true
      proper_view_structure: true
      use_class_based_views: true
    
  frontend:
    django_templates:
      proper_template_inheritance: true
      use_template_tags: true
      csrf_protection: true
```

### 🏢 Enterprise Configuration
```yaml
# Enterprise settings
focus:
  max_files_per_task: 2           # Stricter file limits
  task_timeout_minutes: 45        # Longer tasks allowed
  require_code_review: true       # Mandatory reviews
  
quality_gates:
  security_scan: true
  test_coverage: 90               # Higher coverage required
  complexity_limit: 8             # Lower complexity limit
  documentation_required: true
  
compliance:
  code_signing_required: true
  audit_trail: true
  change_approval_required: true
```

### 🎓 Learning Mode
```yaml
# Configuration for learning/training
focus:
  max_files_per_task: 1           # One file at a time
  educational_hints: true         # Show learning tips
  step_by_step_guidance: true     # Detailed guidance
  
best_practices:
  learning_mode: true
  explain_violations: true        # Explain why it's wrong
  suggest_improvements: true      # Show better alternatives
  provide_examples: true          # Give code examples
```

## 📈 Productivity Metrics

### 📊 Tracking & Analytics
```bash
productivity
# 📊 Productivity Metrics:
# Tasks Completed: 5
# Files Created: 12
# Lines Written: 847
# Time Focused: 3h 45m
# Session Time: 4h 20m
# Focus Efficiency: 86.5%
```

### 🎯 Focus Scoring Algorithm
```python
# Focus Score Calculation (0-100)
base_score = 100

# Penalties:
# - Creating too many files: -10 per extra file
# - Best practice violations: -5 per violation  
# - Task switching: -15 per switch
# - Timeout violations: -20 per timeout

# Bonuses:
# + Task completion: +10 per task
# + Following best practices: +5 per file
# + Staying focused: +1 per focused hour
```

### 📝 Changelog Auto-Generation
```markdown
# 📝 Changelog

## [2024-12-05]

- ✅ **Feature**: Setup project structure
  - Created main directories
  - Setup configuration files
  - Initialize version control

- ✅ **Feature**: Implement authentication system  
  - Created user model
  - Implemented login/register endpoints
  - Added JWT token management

- ✅ **Bugfix**: Fix user input validation
  - Added validation for all forms
  - Implemented sanitization
```

## 🏆 Success Patterns

### 🎯 High-Productivity LLM Session
1. **Start with `show_tasks`** - Know what to do
2. **Pick high-priority task** - Focus on important work
3. **Start task formally** - `start_task <id>`
4. **Work only on that task** - No distractions
5. **Follow best practices** - Quality over speed
6. **Complete task** - `complete_task`
7. **Move to next task** - Maintain momentum

### 📚 Learning & Improvement
1. **Review violations** - Learn from feedback
2. **Study best practices** - Understand the why
3. **Practice patterns** - Build good habits
4. **Track metrics** - Measure improvement
5. **Adjust configuration** - Fine-tune for team

### 🎪 Anti-Patterns to Avoid
❌ **Task hopping** - Starting multiple tasks
❌ **Ignoring best practices** - Rushing without quality
❌ **Creating too many files** - Losing focus
❌ **Skipping documentation** - No context for others
❌ **Not completing tasks** - Leaving things unfinished

## 🚀 Getting Started Checklist

- [ ] Download `llmtask.py`
- [ ] Run initialization: `python3 llmtask.py`
- [ ] Activate shell: `source ~/.llmtask_shell.sh`
- [ ] Review configuration: `.llmcontrol.yaml`
- [ ] Customize best practices for your project
- [ ] Add initial tasks to `TODO.yaml`
- [ ] Start first task: `start_task 1`
- [ ] Complete focused work session
- [ ] Review productivity metrics
- [ ] Adjust configuration based on results

**One file controls everything - maximum focus, minimum chaos! 🎯**