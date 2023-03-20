\LoadClass[11pt]{article}

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{eco_375_paper}

\RequirePackage[letterpaper, margin=0.75in]{geometry}
\RequirePackage{booktabs} % for tables
\RequirePackage{graphicx} % for graphics
\RequirePackage{sectsty} % Specify section formatting
\RequirePackage{tgadventor} % sans-serif font for headings
\RequirePackage{charter} % serif font for body text
\RequirePackage{longtable}
\RequirePackage{amsmath}
\RequirePackage{lscape}

\RequirePackage{setspace}
\doublespacing
	
\sectionfont{\sffamily}
\subsectionfont{\sffamily}
\subsubsectionfont{\sffamily}

\graphicspath{{\opath/}}	

% Path for Jacob
\newcommand{\opath}{C:/Users/lijia/OneDrive - University of Toronto/Documents/School/1-5 ECO375/ECO375 Project/3 - output}
% Path for Ben
%\newcommand{\opath}{}

\newcommand{\ltable}[2]{
	\begin{scriptsize}
	\centering
	\input{\opath/#1}
	\label{#2}
	\end{scriptsize}
}

\newcommand{\datatable}[3]{ % for regression output
	\begin{small}
	\begin{table}[h]
	\centering
	\input{\opath/#1}
	\label{#2}
	\caption{#3}
	\end{table}
	\end{small}
}

\newcommand{\datatableii}[4]{ % for regression output that needs 2 tables
	\begin{small}
	\begin{table}[h]
	\centering
	\input{\opath/#1}
	\input{\opath/#2}
	\label{#3}
	\caption{#4}
	\end{table}
	\end{small}
}

\newcommand{\datatableiii}[5]{ % for regression output that needs 3 tables
	\begin{small}
	\begin{table}[h]
	\centering
	\input{\opath/#1}
	\input{\opath/#2}
	\input{\opath/#3}
	\label{#4}
	\caption{#5}
	\end{table}
	\end{small}
}

\newcommand{\newfigure}[4][0.8]{
	\begin{figure}[h]
	\centering
	\includegraphics[width=#1\linewidth]{#2}
	\caption{#4}
	\label{#3}
	\end{figure}
}

\newcommand{\imagedatatable}[2]{
	\begin{table}[h!]
	\centering
	\includegraphics[width=0.8\linewidth]{#1}
	\caption{#2}
	\end{table}
}
\newcommand{\imagedatatableiii}[4]{
	\begin{table}[h!]
	\centering
	\includegraphics[width=0.9\linewidth]{#1}
	\includegraphics[width=0.9\linewidth]{#2}
	\includegraphics[width=0.9\linewidth]{#3}
	\caption{#4}
	\end{table}
}