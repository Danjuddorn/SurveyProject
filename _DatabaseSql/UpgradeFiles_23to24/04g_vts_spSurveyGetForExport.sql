USE [DBNAME]
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
/// returns the full survey form's questions
/// </summary>
*/

ALTER PROCEDURE [dbo].[vts_spSurveyGetForExport]  @SurveyID int AS


SELECT DISTINCT vts_tbAnswerType.* FROM vts_tbAnswerType
INNER JOIN vts_tbAnswer 
	ON vts_tbAnswer.AnswerTypeID = vts_tbAnswerType.AnswerTypeID
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID

SELECT DISTINCT vts_tbRegularExpression.* FROM vts_tbRegularExpression
INNER JOIN vts_tbAnswer 
	ON vts_tbAnswer.RegularExpressionID = vts_tbRegularExpression.RegularExpressionID
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID

SELECT 
	SurveyID,
	Title,
	RedirectionURL, 
	OpenDate,
	CloseDate,
	ThankYouMessage,
	NavigationEnabled,
	ProgressDisplayModeId,
	ResumeModeId,
	Scored,
	Activated,
	Archive,
	ResultsDisplayTimes,
	SurveyDisplayTimes,
	CreationDate,
	QuestionNumberingDisabled,
	MultiLanguageModeId,
MultiLanguageVariable
FROM vts_tbSurvey WHERE SurveyID = @SurveyID

-- Get main questions and answers
SELECT 
	QuestionID,
	SurveyID,
	ParentQuestionID,
	QuestionText, 
	vts_tbQuestion.SelectionModeId,
	LayoutModeId,
	MinSelectionRequired,
	MaxSelectionAllowed,
	RandomizeAnswers,
	RatingEnabled,
	ColumnsNumber,
	QuestionPipeAlias,
	PageNumber,
	DisplayOrder,
	QuestionIDText,
	HelpText,
	Alias,
	ShowHelpText,
	QuestionId as OldQuestionId,
	QuestionGroupID
FROM vts_tbQuestion 
WHERE SurveyID = @SurveyID AND ParentQuestionID is null

SELECT
	vts_tbAnswer.AnswerID, 
	vts_tbAnswer.QuestionID,
	AnswerText,
	ImageURL,
	DefaultText,
	AnswerPipeAlias,
	vts_tbAnswer.DisplayOrder,
	ScorePoint,
	RatePart,
	Selected,
	AnswerTypeID,
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
    vts_tbAnswer.AnswerID as OldAnswerId,
	CssClass
FROM vts_tbAnswer
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID AND vts_tbQuestion.ParentQuestionID is null

SELECT 
	PublisherAnswerID,
	SubscriberAnswerID,
	vts_tbAnswer.QuestionId
FROM vts_tbAnswerConnection
INNER JOIN vts_tbAnswer
	ON vts_tbAnswer.AnswerId = PublisherAnswerID
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID AND vts_tbQuestion.ParentQuestionID is null

-- Retrieves all child questions and their answers
SELECT 
	ParentQuestionID,
	QuestionText
FROM vts_tbQuestion 
WHERE SurveyID = @SurveyID AND ParentQuestionID is not null

SELECT vts_tbAnswerProperty.AnswerId, Properties
FROM vts_tbAnswerProperty
INNER JOIN vts_tbAnswer
	ON vts_tbAnswerProperty.AnswerID = vts_tbAnswer.AnswerID  
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID AND vts_tbQuestion.ParentQuestionID is null


SELECT 
	DeleteSectionLinkText,
	EditSectionLinkText,
	UpdateSectionLinkText,
	AddSectionLinkText,
	vts_tbQuestionSectionOption.QuestionId,
	MaxSections,
	RepeatableSectionModeId
FROM vts_tbQuestionSectionOption
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbQuestionSectionOption.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID AND vts_tbQuestion.ParentQuestionID is null


SELECT vts_tbQuestionSectionGridAnswer.QuestionID, AnswerID 
FROM vts_tbQuestionSectionGridAnswer 
INNER JOIN vts_tbQuestion 
	ON vts_tbQuestion.QuestionID = vts_tbQuestionSectionGridAnswer.QuestionID  
WHERE vts_tbQuestion.SurveyID = @SurveyID AND vts_tbQuestion.ParentQuestionID is null

SELECT SurveyId,LanguageCode,DefaultLanguage 
FROM  vts_tbSurveyLanguage WHERE surveyId=@SurveyId;

SELECT [LanguageItemId]
      ,[LanguageCode]
      ,[LanguageMessageTypeId]
      ,[ItemText]
  FROM [dbo].[vts_tbMultiLanguageText]
  where( 
   languageMessageTypeId=10 or
  ([LanguageItemId]=@SurveyID and [LanguageMessageTypeId] in(4,5))
  OR( [LanguageItemId] in (SELECT questionid from vts_tbQuestion where SurveyId=@SurveyID) and
  [LanguageMessageTypeId] in(3,11,12))
  OR( [LanguageItemId] in (SELECT answerid from 
  vts_tbQuestion as q inner join 
  vts_tbAnswer as ans on  q.QuestionId=ans.QuestionId where q.SurveyId=@SurveyID ) and
  [LanguageMessageTypeId] in(1,2,13)))
 and len(ItemText) !=0
 or LanguageItemId in(
  --
  SELECT g.ID
   FROM vts_tbQuestionGroups AS g
  WHERE g.ID  IN(
  SELECT q.QuestionGroupID FROM vts_tbQuestion AS  q WHERE SurveyId=@SurveyID)
  UNION
  SELECT g.ID FROM vts_tbQuestionGroups AS g
  WHERE g.ID IN(
  SELECT g.ParentGroupID FROM vts_tbQuestionGroups AS g
  WHERE g.ID  IN(
  SELECT q.QuestionGroupID FROM vts_tbQuestion AS  q WHERE SurveyId=@SurveyID)
  )
  
 )
  
  --
  -- Select all required groups and their parent groups
  --
  SELECT g.ID,g.ParentGroupID,g.GroupName,g.DisplayOrder,g.ID OldId
   FROM vts_tbQuestionGroups AS g
  WHERE g.ID  IN(
  SELECT q.QuestionGroupID FROM vts_tbQuestion AS  q WHERE SurveyId=@SurveyID)
  UNION
  SELECT g.ID,g.ParentGroupID,g.GroupName,g.DisplayOrder ,g.ID OldId FROM vts_tbQuestionGroups AS g
  WHERE g.ID IN(
  SELECT g.ParentGroupID FROM vts_tbQuestionGroups AS g
  WHERE g.ID  IN(
  SELECT q.QuestionGroupID FROM vts_tbQuestion AS  q WHERE SurveyId=@SurveyID)
  )
  
