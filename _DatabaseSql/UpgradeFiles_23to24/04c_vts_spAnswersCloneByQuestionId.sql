USE [DBNAME]
/****** Object:  StoredProcedure [dbo].[vts_spAnswersCloneByQuestionId]    Script Date: 4/14/2015 11:44:27 AM ******/
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
*/
ALTER PROCEDURE [dbo].[vts_spAnswersCloneByQuestionId] 
	@QuestionID int,
	@ClonedQuestionId int  
AS
BEGIN TRAN CloneAnswers
-- Clone the answer
INSERT INTO vts_tbAnswer  
	(QuestionID, 
	AnswerTypeID, 
	AnswerText,
	ImageURL,
	RatePart,
	DisplayOrder,
	Selected,
	DefaultText,
	ScorePoint,
	AnswerPipeAlias,
	RegularExpressionId,
	Mandatory,
	AnswerIDText,
	AnswerAlias,
	SliderRange,
	SliderValue,
	SliderMin,
	SliderMax,
	SliderAnimate,
	SliderStep,
	CssClass)
SELECT      
	@ClonedQuestionID, 
	AnswerTypeID, 
	AnswerText, 
	ImageURL,
	RatePart,
	DisplayOrder,
	Selected,
	DefaultText,
	ScorePoint,
	AnswerPipeAlias,
	RegularExpressionId,
	Mandatory,
	AnswerIDText,
	AnswerAlias,
	SliderRange,
	SliderValue,
	SliderMin,
	SliderMax,
	SliderAnimate,
	SliderStep,
	CssClass
FROM vts_tbAnswer WHERE QuestionID = @QuestionID

--- Clone any available answer multi language text or answer default value in different languages
INSERT INTO vts_tbMultiLanguageText
	(LanguageItemID, LanguageCode, LanguageMessageTypeID, ItemText)
SELECT      
	LanguageItemID = 
	(select answerId from vts_tbAnswer WHERE QuestionId = @ClonedQuestionId AND 
		DisplayOrder = (select DisplayOrder FROM vts_tbAnswer WHERE AnswerId = A.AnswerID)),
	LanguageCode, LanguageMessageTypeID, ItemText 
FROM vts_tbMultiLanguageText
INNER JOIN vts_tbAnswer A
	ON vts_tbMultiLanguageText.LanguageItemID = A.AnswerId
WHERE QuestionID = @QuestionID AND (LanguageMessageTypeID = 1 OR LanguageMessageTypeID = 2 OR LanguageMessageTypeID = 13)


INSERT INTO vts_tbAnswerProperty
	(AnswerId,
	Properties)
SELECT      
	AnswerId = 
	(select answerId from vts_tbAnswer WHERE QuestionId = @ClonedQuestionId AND 
		DisplayOrder = (select DisplayOrder FROM vts_tbAnswer WHERE AnswerId = A.AnswerID)),
	Properties 
FROM vts_tbAnswerProperty
INNER JOIN vts_tbAnswer A
	ON vts_tbAnswerProperty.AnswerID = A.AnswerId
WHERE QuestionID = @QuestionID

exec vts_spAnswerConnectionCloneByQuestionId @QuestionID, @ClonedQuestionId

COMMIT TRAN CloneAnswers


