\LoadClass[12pt]{article}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{eco_375_paper}

% for page setup
\RequirePackage[letterpaper, margin=1in]{geometry}
\RequirePackage{lscape}

% for math
\RequirePackage{amsmath} % for equations
\RequirePackage{bm} % for bold math

% for tables
\RequirePackage{longtable}
\RequirePackage{booktabs}

% for figures
\RequirePackage{graphicx} % for graphics
\RequirePackage{caption}
\RequirePackage{subcaption} % for side-by-side figures

% citations
\usepackage[backend=biber,
			style=apa,
			sorting=nyt]{biblatex}
\nocite{*} % use entire reference list

% paragraph formatting
\RequirePackage{setspace}
\onehalfspacing
\setlength{\parindent}{20pt}
\usepackage{indentfirst}
\RequirePackage{times} % serif font for body text
	
% heading formatting
\RequirePackage{titlesec}
\RequirePackage{tgadventor} % sans-serif font for headings
\titleformat*{\section}{\Large\sffamily\bfseries}
\titlespacing\section{0pt}{6pt plus 2pt minus 2pt}{6pt plus 2pt minus 2pt}

\graphicspath{{\opath/}}	

% Path for Jacob
\newcommand{\opath}{C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/3 - output}
% Path for Ben
%\newcommand{\opath}{}

\newcommand{\datatable}[4][normalsize]{ % for regression output
	\begin{table}[h]
	\begin{#1}
	\centering
	\input{\opath/#2}
	\caption{#4}
	\label{table:#3}
	\end{#1}
	\end{table}
}

\newcommand{\newfigure}[4][0.8]{
	\begin{figure}[h]
	\centering
	\includegraphics[width=#1\linewidth]{#2}
	\caption{#4}
	\label{fig:#3}
	\end{figure}
}

\newcommand{\newsubfig}[5][1]{
	\begin{figure}[h]
		\centering
		\begin{subfigure}{0.5\linewidth}
		  \centering
		  \includegraphics[width=#1\linewidth]{#2}
		\end{subfigure}%
		\begin{subfigure}{0.5\linewidth}
		  \centering
		  \includegraphics[width=#1\linewidth]{#3}
		\end{subfigure}
		\caption{#4}
		\label{fig:#5}
	\end{figure}
}
