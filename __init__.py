"""
TaskGuard - A Python package for task management and monitoring.
"""

__version__ = "0.1.0"

# Import main components to make them available at the package level
from .taskguard import TaskGuard  # noqa: F401
from .local_llm_interface import LocalLLMInterface  # noqa: F401

__all__ = ['TaskGuard', 'LocalLLMInterface']
