USE [DBNAME]
/****** Object:  StoredProcedure [dbo].[vts_spAnswerGetDetails]    Script Date: 4/14/2015 11:48:56 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	Survey changes: copyright (c) 2010, Fryslan Webservices TM (http://survey.codeplex.com)	

	NSurvey - The web survey and form engine
	Copyright (c) 2004, 2005 Thomas Zumbrunn. (http://www.nsurvey.org)

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

/// <summary>
/// Get all question's answers
/// </summary>
/// <param name="@QuestionID">
/// ID of the question from which we want the answers
/// </param>
*/
ALTER PROCEDURE [dbo].[vts_spAnswerGetDetails] @AnswerID int, @LanguageCode nvarchar(50) AS
SELECT 
	AnswerID,
	vts_tbAnswer.AnswerTypeID,
	QuestionId,
	AnswerText = 
		CASE @LanguageCode
		WHEN null THEN
			AnswerText 
		WHEN '' THEN
			AnswerText 
		ELSE
			IsNull((SELECT ItemText FROM 
			vts_tbMultiLanguageText WHERE
			LanguageItemId = vts_tbAnswer.AnswerID AND
			LanguageMessageTypeId = 1 AND
			LanguageCode = @LanguageCode), AnswerText)		
		END,
		AnswerAlias = 
		CASE @LanguageCode
		WHEN null THEN
			AnswerAlias
		WHEN '' THEN
			AnswerAlias
		ELSE
			IsNull((SELECT ItemText FROM 
			vts_tbMultiLanguageText WHERE
			LanguageItemId = vts_tbAnswer.AnswerID AND
			LanguageMessageTypeId = 13 AND
			LanguageCode = @LanguageCode), AnswerAlias)		
		END,
	ImageURL, 
	(SELECT count(*) FROM vts_tbVoterAnswers INNER JOIN vts_tbVoter ON vts_tbVoter.VoterID = vts_tbVoterAnswers.VoterID WHERE  vts_tbVoter.Validated<>0 AND AnswerID = vts_tbAnswer.AnswerID) as VoteCount,
	RatePart,
	Selected,
	ScorePoint,
	DefaultText = 
		CASE @LanguageCode 
		WHEN null THEN
			DefaultText 
		WHEN '' THEN
			DefaultText 
		ELSE
			IsNull((SELECT ItemText FROM 
			vts_tbMultiLanguageText WHERE
			LanguageItemId = vts_tbAnswer.AnswerID AND
			LanguageMessageTypeId = 2 AND
			LanguageCode = @LanguageCode), null)		
		END,
	FieldWidth,
	FieldHeight,
	FieldLength,
	TypeMode,	
	XMLDatasource,
	DataSource,
	JavascriptCode,
	JavascriptFunctionName,
	JavascriptErrorMessage,
	TypeNameSpace,
	TypeAssembly,
	AnswerPipeAlias,
	Mandatory,
	RegExpression,
	RegExMessage,
	vts_tbAnswer.RegularExpressionId,
	AnswerIDText,
	SliderRange,
	SliderValue,
	SliderMin,
	SliderMax,
	SliderAnimate,
	SliderStep,
	CssClass
		
FROM vts_tbAnswer
INNER JOIN vts_tbAnswerType 
	ON vts_tbAnswer.AnswerTypeID = vts_tbAnswerType.AnswerTypeID
LEFT JOIN vts_tbRegularExpression
	ON vts_tbAnswer.RegularExpressionId = vts_tbRegularExpression.RegularExpressionId
WHERE AnswerID=@AnswerID



/* vts_spSurveyGetForExport  */

