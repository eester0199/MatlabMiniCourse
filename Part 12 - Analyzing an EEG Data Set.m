%==========================================================================
% MATLAB Mini-Course Part 12 - Analyzing an EEG data set
%==========================================================================
% written by ee (eester@unr.edu), Spring 2022

%-----Overview-----

% The examples used in this software are modified from an EEG training
% workshop I ran in summer 2021. It shows you how to read data from our
% lab's EEG system, perform some basic preprocessing steps, and generate
% some output files. 

% The steps below are a pretty good example of our lab's "standard" EEG
% preprocessing pipeline, where you perform the same steps (e.g.,
% resampling, filtering, etc. in a specific order). I've tried to comment
% everything thoroughly so you can understand what steps are performing
% what processes and why, but a complete explanation of all the steps is
% beyond the range of this tutorial. 

% If you want to learn more, I suggest you borrow our lab's copy of Steve
% Luck's book on Event-related Potentials or Mike X. Cohen's book on
% analyzing neural time-series data. 

% NOTE: To implement the analyses in this example you'll need a copy of
% EEGLAB, an open-source toolbox of MATLAB functions designed for EEG data
% analysis. You can download it for free here:
% https://sccn.ucsd.edu/eeglab/download.php

%-----The Demo Experiment-----

% We ran a simple visual oddball detection task. On each trial, the subject
% reported whether they saw and "X" or an "O" presented above a fixation
% point. X's occurred on 80% of trials, O's occurred on 20% of trials.
% Prior research has shown that a particular component of the EEG signal
% called the P300 (a positive going potential observed ~300 msec after
% stimulus onset; sometimes also called the P3 waveform) is larger
% following presentation of a rare target compared to a standard target
% (e.g., Donchin et al., Annals NY Academy of Science 425, 1984). This
% tutorial will use EEGLAB to walk you through some basic preprocessing
% steps. Eventually, we'll generate some grand-averaged waveforms
% time-locked to stimulus onset, then sort those waveforms according to
% target type so we can see whether the P3 is in fact bigger during oddball
% trials!

%--------------------------------------------------------------------------
% user defined parameters
%--------------------------------------------------------------------------

subject = '01';                                                             % enter the subject number that you want to analyze
root = [pwd,'\EEG Data\'];                                                  % grab an index into the current matlab path (try typing "pwd" - without quotes - at the command line and see what happens

%--------------------------------------------------------------------------
% preprocessing parameters (user-defined)
%--------------------------------------------------------------------------

resampRate = 250;                                                           % used for temporal downsampling (e.g., from 1000 to 250 Hz)
bandpassLow = 1;                                                            % used during filtering - attenuate all frequencies below this
bandpassHigh = 10;                                                          % used during filtering - attenuate all frequencies above this
rerefElec = 20;                                                             % corresponds to electrode site TP10, i.e., our right mastoid electrode
baselineInterval = [-250,-1];                                               % basline correct the data using this interval relative to stimulus onset (in msec)

% event codes
ec = {'S111','S112'};                                                       % corresponds to stimulus onset during "X" vs. "O" trials
epochLength = [-.5,1];                                                       % how big of a window should we carve out around each event (in sec, relative to event time)

%==========================================================================
% path-setting
%==========================================================================

% add the EEG folder to MATLAB's current path, then launch eeglab!
addpath([root,'eeglab2021.0\']); eeglab

% not really necessary for this demo, but also add the "supportFuncs"
% folder to MATLAB's path. This contains some custom functions I've written
% over the years for various purposes. 
addpath([root,'supportFuncs\']);

%==========================================================================
% quickly analyze this subject's behavioral data. we'll use this as an
% index of different event types (i.e., whether an "X" or an "O" was
% presented on each trial. This information is also stored in the "eeg"
% structure we'll create below, but it's easier to access this way. 
%==========================================================================

% transform the subject ID above from a cell variable to a string variable.
sn = char(subject);
load([root,'s',sn,'\',sn,'_oddballTask.mat']);

% the information we want is stored in stim.type (1 = X, 2 = 0)
stimType = stim.type;

% if we want, we can do a quick analysis to see what the subject's
% behavioral data look like. we should see longer response times and more
% mistakes for infrequent than frequent stimuli:

figure(101),clf
subplot(1,2,1)
bar(1,mean(stim.acc(stim.type==1)),'b'),hold on
bar(2,mean(stim.acc(stim.type==2)),'r')
set(gca,'FontSize',24,'box','off','YLim',[.5,1],'Xtick',[]);
ylabel('Accuracy'); legend('Frequent','Infrequent')
subplot(1,2,2)
bar(1,nanmean(stim.rt(stim.type==1)),'b'),hold on
bar(2,nanmean(stim.rt(stim.type==2)),'r')
set(gca,'FontSize',24,'box','off','YLim',[0,.5],'Xtick',[]);
ylabel('RT (sec)'); 

% ok, looks like errors are more frequent during oddball trials, while
% response times are pretty much the same (at least for this subject)

%==========================================================================
% load the eeg data into matlab (this can take a bit, depending on your
% computer)
%==========================================================================

% this snippet of code calls the eeglab function "loadbv", points that 
% function towards the relevant .vhdr file name, and tells the function to 
% only import data from the first 65 channels (we didn't use 66 and 67 
% in this recording)
eeg = pop_loadbv([root,'s',sn,'\'],[sn,'.vhdr'],[],1:65);                   

% NOTE: You will make your life a lot easier if you pick and stick to a
% consistent file naming nomenclature! When starting a new experiment,
% subject #1 is 01, subject 2 is 02, etc. I always use the same ID for the 
% behavioral data (MATLAB) and the eeg data (.vhdr, .vmrk, .eeg). Then, I
% go to my analysis computer and create a folder on the desktop (or
% wherever I want to put it) and name it after the experiment I'm running
% (in this case on nevadabox, "eeg_data". Then I create a subfolder with
% the subject's ID (in this case, 11) and put all of his or her data into
% it. I also add the eeglab and supportFuncs folder in the top directory.
% If I was going to run a second subject in this task, I'd use the subject
% IF "12". This way, all I have to do to analyze a new subject's data is
% change the "subject" variable at the very top of this script

%==========================================================================
% do some poking around
%==========================================================================

% the EEG data you read in will be stored in a structure called eeg. try
% typing "eeg" at the command line (no quotes) and see what happens. 

% right now, the most interesting part of our data file is the eeg.data
% variable. It should be a 65 by ~680,000 matrix. That's a lot of numbers!
% To get a sense of what we're dealing with, let's try plotting the
% response of a single electrode over the course of the entire recording
% session. For convenience we'll use electrode site Oz, which is in the
% center of the head on top of occipital cortex. 

ozLoc = 16;                             % which of the 65 electrodes corresponds to site Oz?
figure(1),clf
plot(eeg.data(ozLoc,:))

% looks like a weird-ass strand of spaghetti. the numbers on the x-axis of
% the plot are time; the numbers on the y-axis are volts. The voltage isn't
% centered at zero (yet) because this these data contain DC-offset, i.e.,
% random background electrical noise in the environment. 

% let's see if we can clean things up a bit!

%==========================================================================
% begin preprocessing!
%==========================================================================

% the first thing I usually do is downsample my data. For the kind of
% analysis we're going to be using here, it doesn't really matter if our
% temporal resolution is 1 msec or 4 msec. Plus, downsampling can
% *drastically* increase the speed of certain analyses. Let's use an EEGLAB
% function to downsample these data from 1000 Hz to 250 Hz (a factor of 4)

eeg = pop_resample(eeg,resampRate);                                         % EEGLAB already knows the sampling rate of the raw data; that's saved in the .vhdr file

% the second thing I do is bandpass filter my data. Check out the data we
% just plotted. See how the voltage is slowly changing over time? That's
% (probably) due to gradual changes in electrode impedance (e.g., the
% electrode gel starts to harden, or the subject starts to sweat which will
% change skin conductance). Also, remember line noise? In the USA that's
% almost always 60 Hz. We can get rid of that too. 

% let's apply a bandpass filter - which will attenuate very low and very
% high frequency signals in our data - and plot the output for electrode Oz.
eeg = pop_eegfiltnew(eeg,bandpassLow,bandpassHigh);

figure(3),clf
plot(eeg.data(ozLoc,:))

% much nicer! We've removed the DC offset, so the data are now centered at
% (or at least near) zero. 

% try re-running this analysis after changing the values of "bandpassLow"
% and "bandpassHigh", and see how that changes the data plotted in figure
% 2. 

%==========================================================================
% epoch!
%==========================================================================

% in this recording, the start of each trial was indexed by an event marker
% (111 = "X" presented, 112 = "O" presented). We really only care about
% data that occurred shortly before or after each trial began, so let's
% sort the data by event markers. We'll go from a 65 x 170925 matrix to a
% 65 (electrode) x 750 (time) x 200 (trials) data matrix. 
eeg = pop_epoch(eeg,ec,epochLength);

% now let's plot a grand-averaged waveform for electrode site Oz by
% averaging across all trials.
figure(4),clf
plot(squeeze(mean(eeg.data(ozLoc,:,:),3)));

% remember that we time locked our data to include events that occurred 1
% second before and 2 seconds after the start of each trial. Since we
% downsampled from 1000 Hz to 250 Hz, it means that each trial started at
% time 250 in the plot you just generated. Lo and behold, there's a big
% voltage fluctuation that occurs just after time 250. This is called a
% visually-evoked potential (VEP), because it was caused by the
% presentation of a visual stimulus. 

% now let's plot a grand average for electrode sites 1:63 (we're ommitting
% 64 and 65 because those correspond to the horizontal and vertical
% electrooculogram, respectively). 
figure(4), clf
plot(squeeze(mean(eeg.data(1:63,:,:),3))');

% you can see that some electrodes look "cleaner" than others. Sometimes,
% no matter what you do, one or two electrodes will have a really high
% impedance. It's also possible for the electrodes to "fail" mid-recording,
% but this is very rare (using our brainproducts system one electrode dies
% every 9-12 months). Still, we don't want to be analyzing crappy data!
% Here you have solutions. You can (1) identify and throw out the data from
% each bad electrode, or (2), identify and throw out the data from each bad
% electrode, then generate a "best guess" for that electrode's true
% response from the responses of neighboring scalp electrodes. The latter
% is called interpolation. 

% first let's see if we have any crappy channels. I'm going to make a call
% to an EEGLAB function called rejchan and tell it to scan electrodes 1-63
% and mark any electrode who's average voltage is more than 3 standard
% deviations above the average of neighboring electrodes (corresponds to a
% probablity of about 0.004). 
[~,badElec] = pop_rejchan(eeg,'elec',1:63,'threshold',3,'norm','on');

% a list of electrodes should've been printed at the command line. The
% second column is the electrode site, the 3rd column is the standard
% deviation, and the 4th column is whether EEGLAB thinks it's a crappy
% electrode. To give you a sense of what I mean, let's plot one of the
% nasty channels along with Oz:

figure(5),clf
plot(squeeze(mean(eeg.data(ozLoc,:,:),3)),'b'),hold on
plot(squeeze(mean(eeg.data(32,:,:),3)),'r')

% Notice that most of the electrodes marked by rejchan are frontal sites
% near the forehead - the same electrodes that're likely to be most
% impacted by blinks. That's probably what's confusing the algorithm. To
% confirm, let's replot the data from the last figure but also include the
% vertical EOG channel (65):
figure(5),clf
plot(squeeze(mean(eeg.data(ozLoc,:,:),3)),'b'),hold on
plot(squeeze(mean(eeg.data(32,:,:),3)),'r')
plot(squeeze(eeg.data(65,:,:)),'k')

% all of those huge deflections (black) are blinks. And they happen to
% occur a few hundred msec after the subject responds (not shown). We'll
% deal with blinks a different way, but if you want to try interpolation
% uncomment the code below, run it, and then replot just channels 20 and 32
% eeg = pop_interp(eeg,badElec,'spherical');

% these data were recorded with a left mastoid reference, which means that
% the responses of electrodes near the left mastoid will be more highly
% correlated with responses elsewhere on the scalp. We want an unbiased
% reference (spatially, at least), so let's take the data we have in hand
% and re-reference it to 50% of the right mastoid response, thus producing
% a "mean of the left and right mastoid" reference. 

% re-reference, then drop channel 23 (TP10)
eeg.data = eeg.data-(0.5*(repmat(eeg.data(rerefElec,:,:),size(eeg.data,1),1)));

% last, it's often helpful to baseline correct the data from each electrode
% over a period shortly before the start of each trial. This helps you
% compare absolute voltage deflections from a common reference point (i.e.,
% zero volts). Here, I'll call an EEGLAB function called "rmbase" to do
% that. 
eeg = pop_rmbase(eeg,baselineInterval);

% now plot the response of ALL scalp eectrodes:
figure(6),clf
plot(squeeze(mean(eeg.data(1:63,:,:),3))');

%==========================================================================
% artifact identification & removal (works, needs commenting)
%==========================================================================

eeg = pop_runica(eeg,'icatype','runica');
eeg = pop_saveset(eeg,[root,'s',sn,'/',sn,'_preprocessedData']); % save

%==========================================================================
% ICA Component Removal
%==========================================================================

% there are ways to automatically identify and remove components related to
% eye movements, ekg, muscular artifacts, etc. from your data. Some of
% these methods look better than others. When starting out, I *STRONGLY*
% recommend you plot the components and look at their properties. Certain
% types of events (e.g., blinks) produce very stereotyped components that
% are easy to identify. Other types of events (e.g., ekg) can be much
% harder to spot. Identifying bad components is more an art than a science
% - in the same way that hand-drawing retinotopic maps in MRI data is - but
% it's good to get some practice. Check out the EEGLAB Wiki for more:
% https://eeglab.org/tutorials/06_RejectArtifacts/RunICA.html

% we'll cover this live so you can see the different steps; the EEGLAB
% wiki above also has the relevant information

%==========================================================================
%==========================================================================

% Let's load our artifact-free (or at least artifact-limited) data:
eeg = pop_loadset([sn,'_preprocessedData.set'],[root,'s',sn,'\']);

% now let's sort our data. We want to compare the average EEG waveform
% observed after the onset of each standard stimulus ("X") and each oddball
% stimulus ("O"), also known as an event related potential. 

% the "stimType" variable we created when analyzing the behavioral data
% above has an index of what was presented on each trial. 1 = X, 2 = O. So,
% we can use that to create two grand-averaged waveforms by indexing our
% EEG data appropriately:

data_standard = squeeze(mean(eeg.data(:,:,stimType==1),3));
data_oddball = squeeze(mean(eeg.data(:,:,stimType==2),3));

% the P3 component we want to look at is usually largest over midline
% parietal sites (e.g., 10-20 site Pz). In our recording montage, that
% corresponds to electrode #12: (type eeg.chanlocs.labels at the command line for a list)
pzSite = 12;

figure(8),clf
plot(data_standard(pzSite,:),'b'),hold on
plot(data_oddball(pzSite,:),'r')

% remember that we carved out a window from -1 sec before to 2 sec after
% the start of each trial, then downsampled our data from 1000 to 250 Hz.
% So, in the plot above, stimulus onset occurs at time 250. Let's put in a
% marker so we can see that. 
plot([250,250],get(gca,'YLim'),'k-')

% the P300 usually peaks between 300-400 ms post stimulus; in our case,
% thats about 75-100 units on the x-axis (remember, we downsampled to 250
% Hz). So, let's put in a hash at around 350 msec:
plot([335,335],get(gca,'YLim'),'k--');

% and some other stuff to clean up the axes a bit:
set(gca,'FontSize',24,'box','off','Xtick',250,'XTickLabel',{'0'})
xlabel('Time from onset')
ylabel('\uV');
legend('Standard','Oddball')

% if we wanted, we could compute and compare a time-averaged voltage for
% the standard and oddball over the expected P300 window (e.g., 300-400
% ms):

avgStandard = mean(data_standard(pzSite,325:350),2);
avgOddball = mean(data_oddball(pzSite,325:350),2);

[avgStandard,avgOddball]

% d'oh! for this subject there doesn't seem to be a difference in the
% amplitude of the P300 waveform (if anything, the effect is going in the
% wrong direction, with smaller amplitudes after for the oddball than the
% standard! But, it's important to remember that this is just one subject
% and only 200 trials of data. In a real experiment, you'd be collecting
% many more trials (500+) and running multiple subjects. 

%==========================================================================
% try saving a copy of this script under a different name and play around
% with some of the analysis parameters we set above (e.g., filter cutoffs,
% resampling rates), and try plotting the resposnes of different electrodes
% to get a feel for things. 
%==========================================================================

% Finally: there are many alternative ways to analyze EEG data. This
% example shows the kind of pipeline that my lab typically uses, but you
% have quite a bit of choice in the kinds of parameters you select (e.g.,
% filter cutoffs, re-referencing, rejecting trials contaminated by ocular
% artifacts rather than using ICA to eliminate them. If you're not sure
% what to do for all of these specific steps, then I recommend checking out
% the EEGLAB wiki and/or buying a copy of Steve Luck's "An Introduction to
% the Event Related Potential" book. The latter includes detailed yet
% accessible discussions of different strategies for collecting and
% analyzing EEG data, including pros and cons of different approaches. As
% always, there is no "right" way to do this - pick the approach(es) that is
% most practical for your experimental needs!