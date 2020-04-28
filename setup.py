"""A setuptools based setup module.

See:
https://packaging.python.org/guides/distributing-packages-using-setuptools/
https://github.com/pypa/sampleproject
"""

from setuptools import setup, find_packages
from os import path

here = path.abspath(path.dirname(__file__))

with open(path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='lspb',
    version='0.0.1',
    description='List images in urxvt pixbuf',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='https://github.com/gogoprog/lspb',
    author='gogoprog',
    author_email='gogoprog@gmail.com',
    keywords='list images urxvt terminal',
    package_dir={'': 'build'},
    py_modules=["lspb"],
    python_requires='>=3.5, <4',
    install_requires=['pillow'],
    entry_points={
        'console_scripts': [
            'lspb=lspb:lspb_Main.main',
        ],
    },
)
