USE [DBNAME]
/****** Object:  StoredProcedure [dbo].[vts_spAnswerUpdate]    Script Date: 4/14/2015 11:46:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
/// Updates the settings of an answer
/// </summary>
*/
ALTER PROCEDURE [dbo].[vts_spAnswerUpdate] 
			@AnswerID int,
			@AnswerText nvarchar(4000), 
			@DefaultText nvarchar(4000), 
			@ImageURL nvarchar(1000), 
			@AnswerPipeAlias nvarchar(255),
			@AnswerTypeID int,
			@Selected bit,
			@RatePart bit,
			@ScorePoint int,
			@RegularExpressionId int = null,
			@Mandatory bit,
			@LanguageCode nvarchar(50) = null,
			@AnswerIDText nvarchar(255),
			@AnswerAlias nvarchar(255),		
			@SliderRange nvarchar(3),
			@SliderValue int,
			@SliderMin int,
			@SliderMax int,
			@SliderAnimate bit,
			@SliderStep int,
			@CssClass nvarchar(50)
AS
BEGIN TRAN UpdateAnswer

if @Selected <> 0
BEGIN
-- Clear current selected status if we only one selection is possible for the question
UPDATE vts_tbAnswer SET selected = 0 
WHERE AnswerID IN (
	SELECT AnswerID FROM vts_tbAnswer 
	INNER JOIN vts_tbQuestion
		ON vts_tbAnswer.QuestionID = vts_tbQuestion.QuestionID
	INNER JOIN vts_tbQuestionSelectionMode
		ON vts_tbQuestionSelectionMode.QuestionSelectionModeID = vts_tbQuestion.SelectionModeID
	WHERE 	
		vts_tbAnswer.QuestionID = (SELECT QuestionID FROM vts_tbAnswer WHERE AnswerID = @AnswerID) AND 
		vts_tbQuestionSelectionMode.TypeMode & 16 = 0)
END 
UPDATE vts_tbAnswer
SET	ImageURL = @ImageURL,
	AnswerTypeID = @AnswerTypeID,
	RatePart = @RatePart,
	Selected = @Selected,
	ScorePoint = @ScorePoint,
	AnswerPipeAlias = @AnswerPipeAlias,
	RegularExpressionId = @RegularExpressionId,
	Mandatory = @Mandatory,
	AnswerIDText = @AnswerIDText,
	SliderRange = @SliderRange,
	SliderValue = @SliderValue,
	SliderMin = @SliderMin,
	SliderMax = @SliderMax,
	SliderAnimate = @SliderAnimate,
	SliderStep = @SliderStep,
	CssClass = @CssClass
	
WHERE
	AnswerID = @AnswerID

-- Updates text
IF @LanguageCode is null OR @LanguageCode=''
BEGIN
	UPDATE vts_tbAnswer
	SET 	AnswerText = @AnswerText,
		DefaultText = @DefaultText,
	    AnswerAlias = @AnswerAlias
	WHERE AnswerID = @AnswerID
END
ELSE
BEGIN
	-- Updates localized text
	exec vts_spMultiLanguageTextUpdate @AnswerID, @LanguageCode, 1, @AnswerText
	exec vts_spMultiLanguageTextUpdate @AnswerID, @LanguageCode, 2, @DefaultText
	exec vts_spMultiLanguageTextUpdate @AnswerID, @LanguageCode, 13, @AnswerAlias
END

COMMIT TRAN UpdateAnswer


