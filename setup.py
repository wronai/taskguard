from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="taskguard",
    version="0.1.0",
    author="Tom Sapletta",
    author_email="info@softreck.dev",
    description="A task management and monitoring package",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/wronai/taskguard",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: Apache Software License",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
    install_requires=[
        # Add your project's dependencies here
    ],
    entry_points={
        'console_scripts': [
            'taskguard=taskguard.cli:main',
        ],
    },
)
